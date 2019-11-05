#!groovy
//Only one build can run
properties([disableConcurrentBuilds()])

pipeline {
  agent {
    label 'master'
  }
  options {
    buildDiscarder(logRotator(numToKeepStr: '10', artifactNumToKeepStr: '10'))
    timestamps()
  }
  stages {
    stage("Create stack") {
      steps {
        sh 'echo $HOSTNAME'
        sh 'aws cloudformation deploy --stack-name webservers --template-file ops/cloudformation/webservers.yml --parameter-overrides VPCStackName=DevVPC PuppetScriptVersion=0.0.2 WebAppVersion=0.0.1 HostedZoneName=devopsa3.me.uk Environment=Dev --region us-east-1'
        echo 'build finished'
      }
    }
  }
}
