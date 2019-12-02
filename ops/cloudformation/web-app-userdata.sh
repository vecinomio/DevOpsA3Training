#!/bin/bash

S3PATH=$1
PUPVER=$2
AWSSTACKNAME=$3
AWSREGION=$4

function retryCommand() {
  local ATTEMPTS="$1"
  local SLEEP="$2"
  local FUNCTION="$3"
  for i in $(seq 1 $ATTEMPTS); do
      [ $i == 1 ] || sleep $SLEEP
      eval $FUNCTION && echo $? && return 0 || echo $?
  done
  return 1
}
hostnamectl set-hostname webserver
retryCommand 5 10 'rpm -Uvh https://yum.puppet.com/puppet5-release-el-7.noarch.rpm'
retryCommand 5 10 'yum install -y puppet-agent'
export PATH=$PATH:/opt/aws/bin/:/opt/puppetlabs/bin/:/opt/puppetlabs/puppet/bin/
aws s3 cp "s3://$S3PATH/scripts/puppet-$PUPVER.tar" .
retryCommand 5 10 'tar -C /etc/puppetlabs/ -xvf puppet-$PUPVER.tar'
retryCommand 5 10 'gem install r10k'
retryCommand 5 10 'r10k -v info puppetfile install --puppetfile=/etc/puppetlabs/Puppetfile'
retryCommand 5 10 'puppet apply --test /etc/puppetlabs/code/environments/production/manifests/site.pp
                 [ $? == 2 -o $? == 0 ] && return 0'
retryCommand 5 10 'curl -sS http://localhost:8080/index.jsp | grep "Elastic Beanstalk"'
cfn-signal -e $? --stack $AWSSTACKNAME --resource webAppASG --region $AWSREGION
