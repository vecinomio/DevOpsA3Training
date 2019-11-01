# DevOpsA3Training

## Description:
This instructions provide how to create a VPC Stack using CloudFormation.

## Expected results:
* Custom VPC with public and private subnets in 2 Availability Zones
* All resources in subnets Public0 and Public1 has Internet access through Internet Gateway
* All resources in subnets Private0 and Private1 has Internet access through NAT Gateway


# To create infrastructure:

1. Clone repository from github:
   - git clone https://github.com/IYermakov/DevOpsA3Training.git

2. Set variables:
   - VPCStackName="DevVPC" or "ProdVPC"
   - Environment="Dev" or "Prod"

3. Validate VPC template and Create VPC Stack:
   - aws cloudformation validate-template --template-body file://ops/cloudformation/vpc.yml
   - aws cloudformation deploy --stack-name ${VPCStackName} --template-file ops/cloudformation/vpc.yml --parameter-overrides Environment=${Environment}
