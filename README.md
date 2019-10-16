# DevOpsA3Training
![DevOps A3 Cloud Architecture V3](https://user-images.githubusercontent.com/37980289/66839106-91055e80-ef6e-11e9-9b8a-6984fabf60fa.png)

## Description:
This instruction provides how to create Bastion-host within custom VPC in AWS, according to the image above.
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
  - AutoScalingGroup with only one Bastion-host instance;
  - Bastion has Persistent Storage: /dev/xvdf mounted to /bastionData;
  - Bastion has DNS Record: bastion.<HostedZone>;
  - If Bastion-host falls, ASG will create new one and Persistent Storage will attach to it.

# To create Bastion stack:

   BastionStackName="bastion"
   VPCStackName="DevVPC" or "ProdVPC"
   HostedZone="<HostedZone>"
   Region="us-east-1"

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
                               --parameter-overrides VPCStackName \
                               ${VPCStackName} HostedZone ${HostedZone} \
                               --capabilities CAPABILITY_NAMED_IAM \
                               --region ${Region}
