# DevOpsA3Training
![DevOps A3 Cloud Architecture V2 (5)](https://user-images.githubusercontent.com/37980289/66132663-13506300-e5fe-11e9-8184-85cecea86746.png)

## Description:
This instructions provide how to create infrastructure in AWS according to the
image above.

## Expected results:
* Custom VPC with 3 Subnets (Public0, Private0, Private1)
* All resources in Public subnet has Internet access through Internet Gateway
* All resources in Private subnets has Internet access through NAT Gateway
* Public0 subnet contains:
   - Nat Gateway
   - ElasticLoadBalancer for Web-app AutoScalingGroup
   - ElasticLoadBalancer for Jenkins AutoScalingGroup
   - Bastion-host AutoScalingGroup with Persistent Storage and Elastic IP
   - Jenkins AutoScalingGroup with Persistent Storage
* Private0 subnet contains:
   - Web application AutoScalingGroup
* Private1 subnet contains:
   - Relation DB for application level

# TODO:
1. Clone repository from github
2. Check you default region in AWS (Those templates uses us-east-1 region)
3. Create VPC infrastructure:
   - run command to validate template:
    aws cloudformation validate-template --template-body file://ops/cloudformation/vpc.yml
   - run command to create VPC stack:
     aws cloudformation deploy --stack-name ***The_Name_Of_The_Vpc_Stack*** \
                               --template-file ops/cloudformation/vpc.yml \
                               --parameter-overrides Environment=***Dev or Prod*** \
                               --region ***Region*** \
                               --profile ***Profile***
4. Create Bastion-host AutoScaling Group:
   - run command to validate template:
     aws cloudformation validate-template --template-body file://ops/cloudformation/bastion.yml
   - run command to create Bastion stack:
     aws cloudformation deploy --stack-name ***The_Name_of_The_Bastion_Stack*** \
                               --template-file ops/cloudformation/bastion.yml \
                               --parameter-overrides VPCStackName=***DevVPC or ProdVPC*** \
                               --capabilities CAPABILITY_NAMED_IAM
>>>>>>> 0482724ce83d4535cb67154c772d5817506e0058
