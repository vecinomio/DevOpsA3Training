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
    stage("Build app") {
      steps {
        sh 'cd eb-tomcat-snakes && ./build.sh'
      }
    }
    stage("Build Docker Image") {
      steps {
        script {
          dockerImage = docker.build("054017840000.dkr.ecr.us-east-1.amazonaws.com/snakes:${env.BUILD_ID}")
        }
      }
    }
    stage("Push artifact to ECR") {
      steps {
        sh 'docker push dockerImage'
      }
    }
  }
}
