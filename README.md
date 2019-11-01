# DevOpsA3Training

## Description:
This instructions provide how to create an ALB Stack in custom VPC.

## Expected results:
- Application Load Balancer:
  * ALB has 2 Target Groups: "web" and "jenkins";
  * Web-servers are available at "www.your.hosted.zone";
  * Jenkins is available at "ci.your.hosted.zone";
  * All requests from HTTP redirecting to HTTPS.


# To create Bastion Stack:

1. Clone repository from github:
   - git clone https://github.com/IYermakov/DevOpsA3Training.git

2. Check VPC Stack. It must be up:
   - aws cloudformation describe-stacks --stack-name ${VPCStackName}

3. Set variables:
   - VPCStackName="DevVPC" or "ProdVPC"
   - Environment="Dev" or "Prod"
   - HostedZoneName="" # Put your Hosted Zone Name in quotes. Example: "hostedzone.me.uk"
   - SSLCertificateARN="" # Put your Certificate ARN in quotes.

4. Validate ALB template and Create ALB Stack:
      - aws cloudformation validate-template --template-body \
        file://ops/cloudformation/alb.yml
      - aws cloudformation deploy --stack-name alb \
                                  --template-file ops/cloudformation/alb.yml \
                                  --parameter-overrides VPCStackName=${VPCStackName} \
                                                        HostedZoneName=${HostedZoneName} \
                                                        Environment=${Environment} \
                                                        SSLCertificateARN=${SSLCertificateARN}
