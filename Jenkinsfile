#!groovy
pipeline {
  environment {
    BUILD_SCRIPTS_GIT="https://github.com/iidrees/Packer-Ansible.git"
    BUILD_SCRIPTS='mypipeline'
    BUILD_HOME='/var/lib/jenkins/workspace'
  }
  agent any

  tools {nodejs 'node'}

  stages {
    stage('Checkout: Code') {
      steps {
        sh "mkdir -p $WORKSPACE/repo;\
        git config --global user.email 'idreesibraheem@gmail.com';\
        git config --global user.name 'iidrees';\
        git config --global push.default simple;\
        git clone $BUILD_SCRIPTS_GIT repo/$BUILD_SCRIPTS"
        sh "chmod -R +x $WORKSPACE/repo/$BUILD_SCRIPTS"
      }
    }
    stage('Yum: Updates') {
      steps {
      sh "sudo chmod +x $WORKSPACE/repo/$BUILD_SCRIPTS/ansible.sh"
      sh "sudo $WORKSPACE/repo/$BUILD_SCRIPTS/ansible.sh"
      }
    }
  }
  post {
    always {
      cleanWs()
    }
  }
}
