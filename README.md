# DevOpsA3Training


## Description:
This instruction provides:
  - how to create a VPC Stack with custom VPC.
  - how to create an ALB Stack in custom VPC.
  - how to create a Bastion Stack in custom VPC.
  - how to create Jenkins and Jenkins-ebs stacks in custom VPC.
  - how to create ECR-repo Stack in custom VPC.
  - how to create ECS-cluster Stack in custom VPC.
  - how to create ECS-task Stack in custom VPC.


## Expected results:
- Custom VPC with public and private subnets in 2 Availability Zones
  * All resources in subnets Public0 and Public1 has Internet access through Internet Gateway
  * All resources in subnets Private0 and Private1 has Internet access through NAT Gateway

- Application Load Balancer:
  * ALB has default Target Group;
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

- ECR Repository:
  * Repository has Lifecycle Policy.

- ECS Cluster with ASG for container instances.

- ECS Task:
  * Deploy a service on ECS, hosted in a private subnet, but accessible via a public load balancer.


# To create VPC Stack:
1. Clone repository from github:

       $ git clone https://github.com/IYermakov/DevOpsA3Training.git

2. Set variables:

       $ VPCStackName="DevVPC" or "ProdVPC"
       $ Environment="Dev" or "Prod"

3. Validate VPC template and Create VPC Stack:

       $ aws cloudformation validate-template --template-body file://ops/cloudformation/vpc.yml

       $ aws cloudformation deploy --stack-name ${VPCStackName} --template-file ops/cloudformation/vpc.yml --parameter-overrides Environment=${Environment}


# To create ALB Stack:
1. Check VPC Stack, it must be up:

       $ aws cloudformation describe-stacks --stack-name ${VPCStackName}

2. Set variables:

       $ SSLCertificateARN="" # Put your Certificate ARN in quotes.
   - To get the certificate ARN:

       $ aws acm list-certificates

3. Validate ALB template, Set variables and Create ALB Stack:

       $ aws cloudformation validate-template --template-body file://ops/cloudformation/alb.yml

       $ aws cloudformation deploy --stack-name alb --template-file ops/cloudformation/alb.yml --parameter-overrides VPCStackName=${VPCStackName} Environment=${Environment} SSLCertificateARN=${SSLCertificateARN}


# To create Bastion Stack:
1. Check VPC Stack, it must be up:

       $ aws cloudformation describe-stacks --stack-name ${VPCStackName}

2. Set variables:

       $ HostedZoneName="" # Put your Hosted Zone Name in quotes! Example: "hostedzone.me.uk"

3. Validate Bastion template and Create Bastion Stack:

       $ aws cloudformation validate-template --template-body file://ops/cloudformation/bastion.yml

       $ aws cloudformation deploy --stack-name bastion --template-file ops/cloudformation/bastion.yml --parameter-overrides VPCStackName=${VPCStackName} Environment=${Environment} HostedZoneName=${HostedZoneName} --capabilities CAPABILITY_NAMED_IAM


# To create Jenkins Stack:
1. Check VPC Stack. It must be up:

       $ aws cloudformation describe-stacks --stack-name ${VPCStackName}

2. Check ALB Stack. It must be up:

       $ aws cloudformation describe-stacks --stack-name alb

3. Validate jenkins-ebs template and Create jenkins-ebs Stack:

       $ aws cloudformation validate-template --template-body file://ops/cloudformation/jenkins-ebs.yml

       $ aws cloudformation deploy --stack-name jenkins-ebs --template-file ops/cloudformation/jenkins-ebs.yml --parameter-overrides VPCStackName=${VPCStackName} --capabilities CAPABILITY_IAM

4. Validate Jenkins template and Create Jenkins Stack:

       $ aws cloudformation validate-template --template-body file://ops/cloudformation/jenkins.yml

       $ aws cloudformation deploy --stack-name Jenkins --template-file ops/cloudformation/jenkins.yml --parameter-overrides VPCStackName=${VPCStackName} HostedZoneName=${HostedZoneName} MountScriptVersion=0.0.1 PuppetScriptVersion=0.0.1 --capabilities CAPABILITY_IAM


# To create ECR-repo Stack:
1. Validate ecr-repo template and Create ECR-repo Stack:

       $ aws cloudformation validate-template --template-body file://ops/cloudformation/ecr-repo.yml

       $ aws cloudformation deploy --stack-name ECR-repo --template-file ops/cloudformation/ecr-repo.yml


# To create ECS-cluster Stack:
1. Check VPC Stack. It must be up:

       $ aws cloudformation describe-stacks --stack-name ${VPCStackName}

2. Check ALB Stack. It must be up:

       $ aws cloudformation describe-stacks --stack-name alb

3. Validate ecs-cluster template and Create ECS-cluster Stack:

       $ aws cloudformation validate-template --template-body file://ops/cloudformation/ecs-cluster.yml

       $ aws cloudformation deploy --stack-name ECS-cluster --template-file ops/cloudformation/ecs-cluster.yml --parameter-overrides VPCStackName=${VPCStackName} HostedZoneName=${HostedZoneName} --capabilities CAPABILITY_IAM


# To create ECS-task Stack:
1. Check VPC Stack. It must be up:

       $ aws cloudformation describe-stacks --stack-name ${VPCStackName}

2. Check ALB Stack. It must be up:

       $ aws cloudformation describe-stacks --stack-name alb

3. Check ECS-cluster Stack. It must be up:

       $ aws cloudformation describe-stacks --stack-name ECS-cluster

4. Validate ecs-task template and Create ECS-task Stack:
       $ aws cloudformation validate-template --template-body file://ops/cloudformation/ecs-task.yml

       $ aws cloudformation deploy --stack-name ECS-task --template-file ops/cloudformation/ecs-task.yml --parameter-overrides VPCStackName=${VPCStackName}
