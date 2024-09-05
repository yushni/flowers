pipeline {
    agent any
    stages {
        stage('Build') {
            agent {
                docker {
                    image 'golang:1.22'
                    args '-u root:root'
                }
            }
            steps {
                sh 'CGO_ENABLED=0 GOOS=linux go build -buildvcs=false -o flowers .'
            }
        }
        stage('Docker build') {
            steps {
                sh 'docker build -t flowers .'
            }
        }
    }
    post {
       always {
           cleanWs()
       }
    }
}
