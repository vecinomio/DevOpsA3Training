# DevOpsA3Training

## Description:
This instructions provide how to create a VPC Stack using CloudFormation.
                        - how to create a Bastion Stack in custom VPC.

## Expected results:
* Custom VPC with public and private subnets in 2 Availability Zones
* All resources in subnets Public0 and Public1 has Internet access through Internet Gateway
* All resources in subnets Private0 and Private1 has Internet access through NAT Gateway

- AutoScalingGroup with only one Bastion-host instance:
  * Bastion has Elastic IP;
  * Bastion has Persistent Storage: "/dev/xvdf" mounted to "/bastionData" directory;
  * Bastion has DNS Record: bastion.<HostedZoneName>;
  * If Bastion-host falls, ASG will create new one and Persistent Storage will attach to it.

# To create infrastructure:

1. Clone repository from github:
   - git clone https://github.com/IYermakov/DevOpsA3Training.git

2. Set variables:
   - VPCStackName="DevVPC" or "ProdVPC"
   - Environment="Dev" or "Prod"

3. Validate VPC template and Create VPC Stack:
   - aws cloudformation validate-template --template-body file://ops/cloudformation/vpc.yml
   - aws cloudformation deploy --stack-name ${VPCStackName} --template-file ops/cloudformation/vpc.yml --parameter-overrides Environment=${Environment}

# To create Bastion Stack:

1. Set variable and Check VPC Stack, it must be up:
   - VPCStackName="DevVPC" or "ProdVPC"
   - aws cloudformation describe-stacks --stack-name ${VPCStackName}

2. Validate Bastion template, Set variables and Create Bastion Stack:
   - aws cloudformation validate-template --template-body \
     file://ops/cloudformation/bastion.yml
   - Environment="Dev" or "Prod"
   - HostedZoneName="" # Add your Hosted Zone Name in quotes! Example: "hostedzone.me.uk"
   - aws cloudformation deploy --stack-name bastion \
                               --template-file ops/cloudformation/bastion.yml \
                               --parameter-overrides VPCStackName=${VPCStackName} \
                                                     Environment=${Environment} \
                                                     HostedZoneName=${HostedZoneName} \
                               --capabilities CAPABILITY_NAMED_IAM
