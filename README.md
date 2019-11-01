# DevOpsA3Training

## Description:
This instructions provide how to create Jenkins and Jenkins-ebs stacks in custom VPC.

## Expected results:
- AutoScalingGroup with only one Jenkins-host instance:
  * Jenkins has Persistent Storage: "/dev/sdh" mounted to "/var/lib/jenkins" directory;
  * Jenkins has DNS Record: ci.<HostedZoneName>;
  * If Jenkins-host falls, ASG will create new one and Persistent Storage will attach to it.


# To create Jenkins Stack:

1. Clone repository from github:
   - git clone https://github.com/IYermakov/DevOpsA3Training.git

2. Set variables:
  - VPCStackName="DevVPC" or "ProdVPC"

3. Check VPC Stack. It must be up:
  - aws cloudformation describe-stacks --stack-name ${VPCStackName}

4. Check ALB Stack. It must be up:
  - aws cloudformation describe-stacks --stack-name alb

5. Validate ebs-volume template and Create jenkins-ebs Stack:
  - aws cloudformation validate-template --template-body \
    file://ops/cloudformation/ebs-volume.yml
  - aws cloudformation deploy --stack-name jenkins-ebs \
                              --template-file ops/cloudformation/ebs-volume.yml \
                              --parameter-overrides VPCStackName=${VPCStackName}

6. Validate Jenkins template and Create Jenkins Stack:
   - aws cloudformation validate-template --template-body \
     file://ops/cloudformation/jenkins.yml
   - aws cloudformation deploy --stack-name jenkins \
                               --template-file ops/cloudformation/jenkins.yml \
                               --parameter-overrides VPCStackName=${VPCStackName} MountScriptVersion=0.0.1 PuppetScriptVersion=0.0.1 \
                               --capabilities CAPABILITY_IAM
