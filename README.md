# DevOpsA3Training

## Description:
This instructions provide how to create a Bastion Stack in custom VPC.

## Expected results:
- AutoScalingGroup with only one Bastion-host instance:
  * Bastion has Elastic IP;
  * Bastion has Persistent Storage: "/dev/xvdf" mounted to "/bastionData" directory;
  * Bastion has DNS Record: bastion.<HostedZoneName>;
  * If Bastion-host falls, ASG will create new one and Persistent Storage will attach to it.


# To create Bastion Stack:

1. Clone repository from github:
   - git clone https://github.com/IYermakov/DevOpsA3Training.git

2. Set variable and Check VPC Stack, it must be up:
   - VPCStackName="DevVPC" or "ProdVPC"
   - aws cloudformation describe-stacks --stack-name ${VPCStackName}

3. Validate Bastion template, Set variables and Create Bastion Stack:
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
