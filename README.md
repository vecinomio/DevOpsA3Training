# DevOpsA3Training

## Description:
This instruction provides:
  - how to create a VPC Stack using CloudFormation.
  - how to create an ALB Stack in custom VPC.
  - how to create a Bastion Stack in custom VPC.

## Expected results:
- Custom VPC with public and private subnets in 2 Availability Zones
  * All resources in subnets Public0 and Public1 has Internet access through Internet Gateway
  * All resources in subnets Private0 and Private1 has Internet access through NAT Gateway.

- Application Load Balancer:
  * ALB has 2 Target Groups: "web" and "jenkins";
  * Web-servers are available at "www.your.hosted.zone";
  * Jenkins is available at "ci.your.hosted.zone";
  * All requests from HTTP redirecting to HTTPS.

- AutoScalingGroup with only one Bastion-host instance:
  * Bastion has Elastic IP;
  * Bastion has Persistent Storage: "/dev/xvdf" mounted to "/bastionData" directory;
  * Bastion has DNS Record: bastion.<HostedZoneName>;
  * If Bastion-host falls, ASG will create new one and Persistent Storage will attach to it.


# To create VPC Stack:

1. Clone repository from github:
   - git clone https://github.com/IYermakov/DevOpsA3Training.git

2. Set variables:
   - VPCStackName="DevVPC" or "ProdVPC"
   - Environment="Dev" or "Prod"

3. Validate VPC template and Create VPC Stack:
   - aws cloudformation validate-template --template-body file://ops/cloudformation/vpc.yml
   - aws cloudformation deploy --stack-name ${VPCStackName} --template-file ops/cloudformation/vpc.yml --parameter-overrides Environment=${Environment}


# To create ALB Stack:

1. Check VPC Stack, it must be up:
   - aws cloudformation describe-stacks --stack-name ${VPCStackName}

2. Set variables:
   - SSLCertificateARN="" # Put your Certificate ARN in quotes.

3. Validate ALB template, Set variables and Create ALB Stack:
   - aws cloudformation validate-template --template-body file://ops/cloudformation/alb.yml
   - aws cloudformation deploy --stack-name alb --template-file ops/cloudformation/alb.yml --parameter-overrides VPCStackName=${VPCStackName} HostedZoneName=${HostedZoneName} Environment=${Environment} SSLCertificateARN=${SSLCertificateARN}


# To create Bastion Stack:

1. Check VPC Stack, it must be up:
   - aws cloudformation describe-stacks --stack-name ${VPCStackName}

2. Set variables:
   - HostedZoneName="" # Add your Hosted Zone Name in quotes! Example: "hostedzone.me.uk"

3. Validate Bastion template and Create Bastion Stack:
   - aws cloudformation validate-template --template-body file://ops/cloudformation/bastion.yml
   - aws cloudformation deploy --stack-name bastion --template-file ops/cloudformation/bastion.yml --parameter-overrides VPCStackName=${VPCStackName} Environment=${Environment} HostedZoneName=${HostedZoneName} --capabilities CAPABILITY_NAMED_IAM
