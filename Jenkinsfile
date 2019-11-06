#!groovy
//Only one build can run
properties([disableConcurrentBuilds()])

pipeline {
  agent {
    label 'master'
  }
  options {
    buildDiscarder(logRotator(numToKeepStr: '5', artifactNumToKeepStr: '5'))
    timestamps()
  }
  stages {
    stage("Create stack") {
      steps {
        // sh 'aws cloudformation deploy --stack-name webAppASG --template-file ops/cloudformation/cfn_asg.yml --parameter-overrides VPCStackName=DevVPC PuppetScriptVersion=0.0.1 Environment=Dev --capabilities CAPABILITY_NAMED_IAM --region us-east-1'
        sh 'aws cloudformation deploy --stack-name webservers --template-file ops/cloudformation/webservers.yml --parameter-overrides VPCStackName=DevVPC PuppetScriptVersion=0.0.1 HostedZoneName=devopsa3.me.uk Environment=Dev --capabilities CAPABILITY_NAMED_IAM --region us-east-1'
        echo 'build finished'
      }
    }
    stage("Email Notification"){
      steps {
        mail bcc: '', body: 'Stack was successfully deployed. ', cc: '', from: '', replyTo: '', subject: 'DevopsA3 pipeline job', to: 'vecinomio@gmail.com'
      }
    }
  }
}
