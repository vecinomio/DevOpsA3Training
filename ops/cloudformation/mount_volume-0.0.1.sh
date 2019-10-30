#!/usr/bin/env bash
set -o errexit
set -o nounset

#-------------------------------------------------------------------------------
# Log a message.
#-------------------------------------------------------------------------------
function log() {
  echo 1>&2 "$@"
}

#-------------------------------------------------------------------------------
# Display an error message to standard error and then exit the script with a
# non-zero exit code.
#-------------------------------------------------------------------------------
function error() {
  echo 1>&2 "ERROR: $@"
  echo 1>&2
  exit 1
}

#-------------------------------------------------------------------------------
# Retry 10 times a command until it returns an exit code of zero.
#
# @param $* - The command to run.
#-------------------------------------------------------------------------------
function wait_until() {
#  local counter=0
    for counter in $(seq 1 10); do
      [ $counter -eq 10 ] || sleep 10
        "${@}" && break
        log "Command failed: ${*}"
        log "Retrying..."
    done
}

#-------------------------------------------------------------------------------
# Determine the ID of the currently running EC2 instance.
#-------------------------------------------------------------------------------
function get_ec2_instance_id() {
  /opt/aws/bin/ec2-metadata --instance-id |
  cut -d" " -f2
}

#-------------------------------------------------------------------------------
# Determine current availability zone
#-------------------------------------------------------------------------------
function get_ec2_instance_availability_zone() {
  /opt/aws/bin/ec2-metadata --availability-zone |
  cut -d" " -f2
}

#-------------------------------------------------------------------------------
# Determine which region the currently running instance is in.
#-------------------------------------------------------------------------------
function get_ec2_instance_region() {
  /opt/aws/bin/ec2-metadata --availability-zone |
  cut -d" " -f2 |
  sed "s/.$//g"
}

#-------------------------------------------------------------------------------
# Determine the value of a tag on this instance.
#
# This is determined from the EC2 tags on the current instance.
#-------------------------------------------------------------------------------
function get_ec2_instance_tag() {
  local tag="${1}"
  local region=$(get_ec2_instance_region)
  local instance_id=$(get_ec2_instance_id)
  local value=$(wait_until aws ec2 describe-tags                            \
                    --region "${region}"                                \
                    --filters Name=resource-id,Values="${instance_id}"  \
                              Name=key,Values="${tag}"                  \
                    --output text                                       \
                    --query 'Tags[0].Value')

  echo "${value}"
}

#-------------------------------------------------------------------------------
# Determine last created snapshot ID for Jenkins
#
# @param $1 - The region where the host is located.
#-------------------------------------------------------------------------------
function get_jenkins_snapshot() {
  local region="${1}"

  local snapshot_id=$(wait_until aws ec2 describe-snapshots                                                   \
                        --region ${region}                                                                    \
                        --filters Name=status,Values=completed                                                \
                                  Name=tag:Service,Values=Jenkins                                             \
                        --query 'Snapshots[].[SnapshotId,StartTime] | reverse(sort_by(@, &[1])) | [0] | [0]' \
                        --output text)

  if [[ ${snapshot_id} = "None" || -z ${snapshot_id} ]]; then
    log "Valid snapshot not found."
  else
    log "Found snapshot ${snapshot_id}"
    echo "${snapshot_id}"
  fi
}

#-------------------------------------------------------------------------------
# Determine the physical ID of the assigned EBS data volume to attach and mount
#
# This is determined from the EC2 tags on the current instance.
# @param $1 - The region where the host is located.
#-------------------------------------------------------------------------------
function get_jenkins_data_volume() {
  local region=${1}
  local volume_id=$(wait_until aws ec2 describe-volumes                        \
                         --region ${region}                                    \
                         --filters Name=status,Values=available                \
                                   Name=tag:Service,Values=Jenkins             \
                         --query 'Volumes[].[VolumeId,CreateTime] | reverse(sort_by(@, &[1])) | [0] | [0]'          \
                         --output text)

  if [[ ${volume_id} = "None" || -z ${volume_id} ]]; then
    log "Valid volume not found."
  else
    log "Found volume ${volume_id}"
    echo "${volume_id}"
  fi
}

#-------------------------------------------------------------------------------
# Set hostname.
# @param $1 - The desired hostname of the server.
#-------------------------------------------------------------------------------
function set_hostname() {
  hostnamectl set-hostname "${1}"
}

#-------------------------------------------------------------------------------
# Attach EBS volume and setup to create backup snapshots
# @param $1 - Volume ID
# @param $2 - Device for mount EBS volume
# @param $3 - Current region
#-------------------------------------------------------------------------------
function attach_volume() {
  local volume_id="${1}"
  local device="${2}"
  local region="${3}"

# Attach the EBS data volume as /dev/sdh
  wait_until aws ec2 attach-volume                    \
                 --region ${region}                   \
                 --volume-id ${volume_id}             \
                 --instance-id $(get_ec2_instance_id) \
                 --device ${device}

  #Wait until EBS volume attached.
  while [[ ! -b ${device} ]]; do
    log "Waiting for AWS to finish attaching the EBS volume. Looping..."
    sleep 10
  done
  log "EBS volume ${volume_id} attached."
}

#-------------------------------------------------------------------------------
# Attach, mount, and prepare the Jenkins EBS data volume.
#
# @param $1 - The region where the host is located.
# @param $2 - The current environment
#-------------------------------------------------------------------------------
function mount_jenkins_data_volume() {
  local region="${1}"
  local availability_zone="$(get_ec2_instance_availability_zone)"
  local volume_id="$(get_jenkins_data_volume ${region})"
  local created_volume=""
  local snapshot_id="$(get_jenkins_snapshot ${region})"
  local mount_point="/var/lib/jenkins"
  local device="/dev/sdh"

  #Valid volume found
  if [[ -n "${volume_id}" ]]; then
    log "Attaching valid volume ${volume_id}"
    attach_volume ${volume_id} ${device} ${region}

  #Volume not found but snapshot exists
  elif [[ -n ${snapshot_id} && -z ${volume_id} ]]; then
    #Restore volume from the latest created snapshot
    log "Restoring volume from snapshot ${snapshot_id}"
    created_volume=$(wait_until aws ec2 create-volume                                           \
                   --region ${region}                                                           \
                   --availability-zone ${availability_zone}                                     \
                   --snapshot-id ${snapshot_id}                                                 \
                   --volume-type standard                                                       \
                   --query '[VolumeId]'                                                         \
                   --output text)
    log "Volume ${created_volume} from snapshot ${snapshot_id} restored"

    #Attach volume restored from snapshot
    attach_volume ${created_volume} ${device} ${region}

  #Snapshot not found, volume not found, create new volume
  else
    log "Creating new volume"
    created_volume=$(wait_until aws ec2 create-volume                                           \
                   --region ${region}                                                           \
                   --availability-zone ${availability_zone}                                     \
                   --size 8                                                                  \
                   --volume-type standard                                                       \
                   --query '[VolumeId]'                                                         \
                   --output text)
    log "New volume ${created_volume} created"

    #Attach new volume
    attach_volume ${created_volume} ${device} ${region}

    # Install the xfsprogs package since we need an XFS volume
    wait_until yum install xfsprogs -y
    log "Installed xfsprogs package."
  fi

  # Create a new file system if needed
  if [[ $(blkid -p -u filesystem ${device}) != 0 ]]; then
    mkfs.xfs -f ${device}
  fi

  # Create a mount point
  mkdir -p ${mount_point}
  log "Created mount point."

  # Add a new entry for the volume to /etc/fstab
  cat - >> /etc/fstab <<EOF
# device    mount point              type  options   dump  pass
${device}  ${mount_point}           xfs   defaults  0     0
EOF
  log "Added fstab entry."

  # Mount the file system as /var/lib/jenkins
  mount -t xfs ${device} ${mount_point}
  log "Mounted data volume."
}

#-------------------------------------------------------------------------------
# Set hostname, mount or create volume
#-------------------------------------------------------------------------------
function main() {
  local region=$(get_ec2_instance_region)
  local hostname=""

    while [[ ${#} -gt 0 ]]; do
    case "${1}" in
      --hostname)               hostname="${2}"
                                shift 2 ;;
      *)                        error Unrecognized option "${1}" ;;
    esac
  done

  wait_until yum update -y

  set_hostname ${hostname}
  mount_jenkins_data_volume ${region}
  yum reinstall -y aws-cli aws-cfn-bootstrap
}

main "${@}"
