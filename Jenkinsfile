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
          dockerImage = docker.build("snakes:${env.BUILD_ID}")
        }
      }
    }
    stage("Move Docker Image to ECR") {
      steps {
        script {
          docker.withRegistry('http')
        }
      }
    }
  }
}
