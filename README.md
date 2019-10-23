# DevOpsA3Training
![DevOps A3 Cloud Architecture V3](https://user-images.githubusercontent.com/37980289/67105181-f35d9980-f1d0-11e9-9c9a-13fdf169f8f9.png)

## Description:
This instruction provides how to create infrastructure in AWS, according to the image above.
Resources will create in Public Subnet 0 of custom VPC:
  - Bastion Security Group;
  - Bastion Elastic IP;
  - Bastion DNS Record;
  - Bastion Persistent Volume;
  - Bastion Role with Policies;
  - Bastion Profile;
  - Bastion Launch Configuration: Attaches EIP and EBS to Bastion;
  - Bastion Auto Scaling Group."

## Expected results:
  - Custom VPC with public and private subnets in 2 Availability Zones;
  - AutoScalingGroup with only one Bastion-host instance:
    * Bastion has Elastic IP;
    * Bastion has Persistent Storage: /dev/xvdf mounted to /bastionData directory;
    * Bastion has DNS Record: bastion.<HostedZoneName>;
    * If Bastion-host falls, ASG will create new one and Persistent Storage will attach to it.
  - AutoScalingGroup with only one Jenkins-host instance:
    * Jenkins has Persistent Storage: /dev/xvdf mounted to /bastionData directory;
    * Jenkins has DNS Record: ci.<HostedZoneName>;
    * If Jenkins-host falls, ASG will create new one and Persistent Storage will attach to it.


# To create Bastion stack:

   * BastionStackName="bastion"
   * VPCStackName="DevVPC" or "ProdVPC"
   * HostedZone="your.hosted.zone"
   * Region="us-east-1"

1. Clone repository from github:
   - git clone https://github.com/IYermakov/DevOpsA3Training.git
2. Check VPC Stack. It must be up:
   - aws cloudformation describe-stacks --stack-name ${VPCStackName}
3. Validate bastion template:
   - aws cloudformation validate-template --template-body \
     file://ops/cloudformation/bastion.yml
4. Create Bastion stack:
   - aws cloudformation deploy --stack-name ${BastionStackName} \
                               --template-file ops/cloudformation/bastion.yml \
                               --parameter-overrides VPCStackName=${VPCStackName}  HostedZone=${HostedZone} \
                               --capabilities CAPABILITY_NAMED_IAM \
                               --region ${Region}
