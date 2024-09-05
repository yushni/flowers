pipeline {
    agent {
        docker {
            image 'golang:1.22'
            args '-u root:root'
        }
    }
    stages {
        stage('Build') {
            steps {
                sh 'ls'
                sh 'CGO_ENABLED=0 GOOS=linux go build -buildvcs=false -o flowers .'
                sh 'ls'
            }
        }
    }
    post {
       always {
           cleanWs()
       }
    }
}