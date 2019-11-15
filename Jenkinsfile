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
  environment {
    ECRURI = '054017840000.dkr.ecr.us-east-1.amazonaws.com'
    RepoName = 'snakes'

  }
  stages {
    stage("Build app") {
      steps {
        sh 'cd eb-tomcat-snakes && ./build.sh'
      }
    }
    stage("Build Docker Image") {
      steps {
        script {
          dockerImage = docker.build("${ECRURI}/${RepoName}:${env.BUILD_ID}")
        }
      }
    }
    stage("Push artifact to ECR") {
      steps {
        script {
          sh '$(aws ecr get-login --no-include-email --region us-east-1)'
          docker.withRegistry("https://${ECRURI}") {
            dockerImage.push()
          }
        }
      }
    }
    stage("CleanUp") {
      steps {
        echo "====================== Removing images ====================="
        sh 'docker image prune -af'
        sh 'docker images'
      }
    }
    stage("Create Stack with WebServers") {
      steps {
        sh "aws cloudformation deploy --stack-name webservers --template-file ops/cloudformation/webservers.yml --parameter-overrides VPCStackName=DevVPC HostedZoneName=devopsa3.me.uk Environment=Dev ImageTag=${env.BUILD_ID} --capabilities CAPABILITY_NAMED_IAM --region us-east-1"
      }
    }
  }
}
