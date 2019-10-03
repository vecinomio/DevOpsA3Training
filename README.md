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
   - run command:
     aws cloudformation deploy --stack-name ***VPCStackName*** \
                               --template-file ops/cloudformation/vpc.yml \
                               --parameter-overrides Environment=***Dev or Prod*** \
                               --region ***Region*** \
                               --profile ***Profile***
4. Create Bastion-host AutoScaling Group:
   - run command:
     aws cloudformation deploy --stack-name ***BastionStackName*** \
                               --template-file A3-ASG-bastion.yaml \
                               --parameters-overrides VPCStackName=***DevVPC or ProdVPC*** \
                               --capabilities CAPABILITY_NAMED_IAM
