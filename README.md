# DevOpsA3Training
![DevOps A3 Cloud Architecture V2 (5)](https://user-images.githubusercontent.com/37980289/66132663-13506300-e5fe-11e9-8184-85cecea86746.png)

## Description:
This instruction provides how to create Bastion-host within custom VPC in AWS, according to the image above.

## Expected results:
* Bastion-host in AutoScalingGroup 1-1 with Persistent Storage and SubDomain name.
  - Bastion has SubDomain name: bastion.<---YourDomainName--->
  - If Bastion-host falls, ASG will create new one and Persistent Storage will attach to it.

# TODO:
1. Clone repository from github
2. Check you default region in AWS (Those templates uses us-east-1 region)
3. Check VPC Stack. It must be up.
4. Create Bastion-host AutoScaling Group:
   - run command to validate template:
     aws cloudformation validate-template --template-body file://ops/cloudformation/bastion.yml
   - run command to create Bastion stack:
     aws cloudformation deploy --stack-name ***The_Name_of_The_Bastion_Stack*** \
                               --template-file ops/cloudformation/bastion.yml \
                               --parameter-overrides VPCStackName=***DevVPC or ProdVPC*** HostedZone=<---YourDomainName--->. \
                               --capabilities CAPABILITY_NAMED_IAM
