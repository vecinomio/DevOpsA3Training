# DevOpsA3Training
![DevOps A3 Cloud Architecture V3](https://user-images.githubusercontent.com/37980289/67105181-f35d9980-f1d0-11e9-9c9a-13fdf169f8f9.png)

## Description:
This instruction provides how to create infrastructure in AWS, according to the image above.
Used Stacks:
  - vpc
  - route53zones
  - bastion
  - alb
  - jenkins-ebs-volume
  - jenkins
  - cfn_asg

## Expected results:
  - Custom VPC with public and private subnets in 2 Availability Zones.
  - Hosted Zone.
  - SSL Wildcard Certificate for HTTPS access.
  - Application Load Balancer:
    * ALB has 2 Target Groups: "web" and "jenkins";
    * Web-servers are available at "www.your.hosted.zone";
    * Jenkins is available at "ci.your.hosted.zone".
  - AutoScalingGroup with only one Bastion-host instance:
    * Bastion has Elastic IP;
    * Bastion has Persistent Storage: "/dev/xvdf" mounted to "/bastionData" directory;
    * Bastion has DNS Record: bastion.<HostedZoneName>;
    * If Bastion-host falls, ASG will create new one and Persistent Storage will attach to it.
  - AutoScalingGroup with only one Jenkins-host instance:
    * Jenkins has Persistent Storage: "/dev/sdh" mounted to "/var/lib/jenkins" directory;
    * Jenkins has DNS Record: ci.<HostedZoneName>;
    * If Jenkins-host falls, ASG will create new one and Persistent Storage will attach to it.
  - AutoScalingGroup with WebServers.


# To create infrastructure:

1. Clone repository from github:
   - git clone https://github.com/IYermakov/DevOpsA3Training.git

2. Validate VPC template and Create VPC Stack:
   - aws cloudformation validate-template --template-body \
     file://ops/cloudformation/vpc.yml
   - aws cloudformation deploy --stack-name vpc \
                               --template-file ops/cloudformation/vpc.yml \
                               --parameter-overrides Environment=Dev | Prod
3. Validate route53zones template and Create hostedZone Stack:
   - aws cloudformation validate-template --template-body \
     file://ops/cloudformation/route53zones.yml
   - aws cloudformation deploy --stack-name hostedZone \
                               --template-file ops/cloudformation/route53zones.yml
4. Validate Bastion template and Create Bastion Stack:
   - aws cloudformation validate-template --template-body \
     file://ops/cloudformation/bastion.yml
   - aws cloudformation deploy --stack-name bastion \
                               --template-file ops/cloudformation/bastion.yml \
                               --parameter-overrides VPCStackName=DevVPC | ProdVPC  HostedZoneName=<your.hosted.zone> \
                               --capabilities CAPABILITY_NAMED_IAM
5. Validate ALB template and Create ALB Stack:
  - aws cloudformation validate-template --template-body \
    file://ops/cloudformation/alb.yml
  - aws cloudformation deploy --stack-name alb \
                              --template-file ops/cloudformation/alb.yml \
                              --parameter-overrides VPCStackName=DevVPC | ProdVPC  HostedZoneName=<your.hosted.zone>
6. Validate ebs-volume template and Create Jenkins-ebs-volume Stack:
  - aws cloudformation validate-template --template-body \
    file://ops/cloudformation/ebs-volume.yml
  - aws cloudformation deploy --stack-name jenkins-ebs-volume \
                              --template-file ops/cloudformation/ebs-volume.yml \
                              --parameter-overrides VPCStackName=DevVPC | ProdVPC
7. Validate Jenkins template and Create Jenkins Stack:
  - aws cloudformation validate-template --template-body \
    file://ops/cloudformation/jenkins.yml
  - aws cloudformation deploy --stack-name jenkins \
                              --template-file ops/cloudformation/jenkins.yml \
                              --parameter-overrides VPCStackName=DevVPC | ProdVPC  ScriptVersion=0.0.1 \
                              --capabilities CAPABILITY_IAM
8. Validate Web template and Create Web Stack:
  - aws cloudformation validate-template --template-body \
    file://ops/cloudformation/cfn_asg.yml
  - aws cloudformation deploy --stack-name web \
                              --template-file ops/cloudformation/cfn_asg.yml \
                              --parameter-overrides VPCStackName=DevVPC | ProdVPC  
