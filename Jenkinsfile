pipeline {
    agent {
        docker { image 'golang:1.22' }
    }
    stages {
        stage('Build') {
            steps {
                sh 'RUN CGO_ENABLED=0 GOOS=linux go build -o flowers .'
            }
        }
    }
}