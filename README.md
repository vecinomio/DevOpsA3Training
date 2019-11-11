# DevOpsA3Training

![DevOps A3 Cloud Architecture V3 (1)](https://user-images.githubusercontent.com/23032052/68381416-59976580-015a-11ea-8b66-5352442be2c7.png)


## Description:
This instruction provides:
  - how to create a VPC Stack using CloudFormation.
  - how to create an ALB Stack in custom VPC.
  - how to create a Bastion Stack in custom VPC.
  - how to create Jenkins and Jenkins-ebs stacks in custom VPC.
  - how to create WebApp stack in custom VPC.


## Expected results:
- Custom VPC with public and private subnets in 2 Availability Zones
  * All resources in subnets Public0 and Public1 has Internet access through Internet Gateway
  * All resources in subnets Private0 and Private1 has Internet access through NAT Gateway

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

- AutoScalingGroup with only one Jenkins-host instance:
  * Jenkins has Persistent Storage: "/dev/sdh" mounted to "/var/lib/jenkins" directory;
  * Jenkins has DNS Record: ci.<HostedZoneName>;
  * If Jenkins-host falls, ASG will create new one and Persistent Storage will attach to it.

- AutoScalingGroup with WebApp instances:
  * Backend instances are served via DNS record www.<HostedZoneName>;
  * If one WebApp server falls, ASG will create new one.


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
   # To get the Certificate ARN do: aws acm list-certificates

3. Validate ALB template, Set variables and Create ALB Stack:
   - aws cloudformation validate-template --template-body file://ops/cloudformation/alb.yml
   - aws cloudformation deploy --stack-name alb --template-file ops/cloudformation/alb.yml --parameter-overrides VPCStackName=${VPCStackName} Environment=${Environment} SSLCertificateARN=${SSLCertificateARN}


# To create Bastion Stack:
1. Check VPC Stack, it must be up:
   - aws cloudformation describe-stacks --stack-name ${VPCStackName}

2. Set variables:
   - HostedZoneName="" # Put your Hosted Zone Name in quotes! Example: "hostedzone.me.uk"

3. Validate Bastion template and Create Bastion Stack:
   - aws cloudformation validate-template --template-body file://ops/cloudformation/bastion.yml
   - aws cloudformation deploy --stack-name bastion --template-file ops/cloudformation/bastion.yml --parameter-overrides VPCStackName=${VPCStackName} Environment=${Environment} HostedZoneName=${HostedZoneName} --capabilities CAPABILITY_NAMED_IAM


# To create Jenkins Stack:
1. Check VPC Stack. It must be up:
   - aws cloudformation describe-stacks --stack-name ${VPCStackName}

2. Check ALB Stack. It must be up:
   - aws cloudformation describe-stacks --stack-name alb

3. Validate ebs-volume template and Create jenkins-ebs Stack:
   - aws cloudformation validate-template --template-body file://ops/cloudformation/ebs-volume.yml
   - aws cloudformation deploy --stack-name jenkins-ebs --template-file ops/cloudformation/ebs-volume.yml --parameter-overrides VPCStackName=${VPCStackName} --capabilities CAPABILITY_IAM

4. Validate Jenkins template and Create Jenkins Stack:
   - aws cloudformation validate-template --template-body file://ops/cloudformation/jenkins.yml
   - aws cloudformation deploy --stack-name Jenkins --template-file ops/cloudformation/jenkins.yml --parameter-overrides VPCStackName=${VPCStackName} HostedZoneName=${HostedZoneName} MountScriptVersion=0.0.1 PuppetScriptVersion=0.0.1 --capabilities CAPABILITY_IAM


# To create WebApp Stack:
1. Check VPC Stack. It must be up:
   - aws cloudformation describe-stacks --stack-name ${VPCStackName}

2. Check ALB Stack. It must be up:
   - aws cloudformation describe-stacks --stack-name alb

3. Validate cfn_asg template and Create webApp Stack:
   - aws cloudformation validate-template --template-body file://ops/cloudformation/cfn_asg.yml
   - aws cloudformation deploy --stack-name webAppASG --template-file ops/cloudformation/cfn_asg.yml --parameter-overrides VPCStackName=${VPCStackName} PuppetScriptVersion=0.0.1 --capabilities CAPABILITY_NAMED_IAM
