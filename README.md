# DevOpsA3Training

## Description:
This instruction provides:
  - how to create a VPC Stack using CloudFormation.
  - how to create Jenkins and Jenkins-ebs stacks in custom VPC.

## Expected results:
- Custom VPC with public and private subnets in 2 Availability Zones
  * All resources in subnets Public0 and Public1 has Internet access through Internet Gateway
  * All resources in subnets Private0 and Private1 has Internet access through NAT Gateway

- AutoScalingGroup with only one Jenkins-host instance:
  * Jenkins has Persistent Storage: "/dev/sdh" mounted to "/var/lib/jenkins" directory;
  * Jenkins has DNS Record: ci.<HostedZoneName>;
  * If Jenkins-host falls, ASG will create new one and Persistent Storage will attach to it.


# To create VPC Stack:

1. Clone repository from github:
   - git clone https://github.com/IYermakov/DevOpsA3Training.git

2. Set variables:
   - VPCStackName="DevVPC" or "ProdVPC"
   - Environment="Dev" or "Prod"

3. Validate VPC template and Create VPC Stack:
   - aws cloudformation validate-template --template-body file://ops/cloudformation/vpc.yml
   - aws cloudformation deploy --stack-name ${VPCStackName} --template-file ops/cloudformation/vpc.yml --parameter-overrides Environment=${Environment}


# To create Jenkins Stack:

1. Check VPC Stack. It must be up:
   - aws cloudformation describe-stacks --stack-name ${VPCStackName}

2. Check ALB Stack. It must be up:
   - aws cloudformation describe-stacks --stack-name alb

3. Validate ebs-volume template and Create jenkins-ebs Stack:
   - aws cloudformation validate-template --template-body file://ops/cloudformation/ebs-volume.yml
   - aws cloudformation deploy --stack-name jenkins-ebs --template-file ops/cloudformation/ebs-volume.yml --parameter-overrides VPCStackName=${VPCStackName}

4. Validate Jenkins template and Create Jenkins Stack:
   - aws cloudformation validate-template --template-body file://ops/cloudformation/jenkins.yml
   - aws cloudformation deploy --stack-name jenkins --template-file ops/cloudformation/jenkins.yml --parameter-overrides VPCStackName=${VPCStackName} MountScriptVersion=0.0.1 PuppetScriptVersion=0.0.1 --capabilities CAPABILITY_IAM
