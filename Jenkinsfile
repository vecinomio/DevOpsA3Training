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
        sh 'cd app'
        sh './build.sh'
      }
    }
    stage("Build Docker Image") {
      steps {
        sh 'docker build -t snakes:0.1 .'
      }
    }
  }
}
