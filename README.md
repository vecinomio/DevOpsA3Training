# DevOpsA3Training
![DevOps A3 Cloud Architecture V2](https://user-images.githubusercontent.com/37980289/65879722-1e568980-e399-11e9-8ecf-0f6bf96b818b.png)

## Description:
This instructions provide how to create infrastructure in AWS according to the image above

# TODO:
1. Clone repository from github
2. Check you default region in AWS (This templates uses us-east-1 region)
3. Create VPC infrastructure:
   - run command: aws cloudformation deploy --stack-name A3-VPC --template-file .../path/to/vpc.yaml
4. Create Bastion-host AutoScaling Group:
   - run command: aws cloudformation deploy --stack-name A3-ASG-bastion --template-file .../path/to/A3-ASG-bastion.yaml
