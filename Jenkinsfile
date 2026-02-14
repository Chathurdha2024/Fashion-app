pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = 'dockerhub-credentials'
        DOCKERHUB_USERNAME = 'hasangi123'
        EC2_PUBLIC_IP = '65.0.30.30' 
        EC2_USER = 'ubuntu'
        SSH_KEY_ID = 'fashion-aws-key'
    }

    stages {
        stage('Clone') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/Chathurdha2024/Forever-fashion-app.git',
                    credentialsId: 'github-token'
            }
        }

        stage('Build Frontend Docker Image') {
            steps {
                script {
                    sh "docker build --build-arg VITE_BACKEND_URL=http://${EC2_PUBLIC_IP}:4000 -t ${DOCKERHUB_USERNAME}/forever-fashion-app-frontend:latest ./frontend"
                }
            }
        }

        stage('Build Backend Docker Image') {
            steps {
                script {
                    sh "docker build -t ${DOCKERHUB_USERNAME}/forever-fashion-app-backend:latest ./backend"
                }
            }
        }

        stage('Build Admin Docker Image') {
            steps {
                script {
                    sh "docker build --build-arg VITE_BACKEND_URL=http://${EC2_PUBLIC_IP}:4000 -t ${DOCKERHUB_USERNAME}/forever-fashion-app-admin:latest ./admin"
                }
            }
        }

        stage('Push Frontend Docker Image') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: DOCKERHUB_CREDENTIALS, usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                        sh "echo $PASS | docker login -u $USER --password-stdin"
                        sh "docker push ${DOCKERHUB_USERNAME}/forever-fashion-app-frontend:latest"
                    }
                }
            }
        }

        stage('Push Backend Docker Image') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: DOCKERHUB_CREDENTIALS, usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                        sh "echo $PASS | docker login -u $USER --password-stdin"
                        sh "docker push ${DOCKERHUB_USERNAME}/forever-fashion-app-backend:latest"
                    }
                }
            }
        }

        stage('Push Admin Docker Image') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: DOCKERHUB_CREDENTIALS, usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                        sh "echo $PASS | docker login -u $USER --password-stdin"
                        sh "docker push ${DOCKERHUB_USERNAME}/forever-fashion-app-admin:latest"
                    }
                }
            }
        }
        stage('Deploy to EC2') {
    steps {
        script {
            sshagent(credentials: [SSH_KEY_ID]) {
                // 1. Copy the docker-compose file
                sh "scp -o StrictHostKeyChecking=no docker-compose.yml ${EC2_USER}@${EC2_PUBLIC_IP}:/home/ubuntu/docker-compose.yml"
                
                // 2. SSH and Deploy using a single string of command
                sh "ssh -o StrictHostKeyChecking=no ${EC2_USER}@${EC2_PUBLIC_IP} 'sudo docker compose pull && sudo docker compose up -d && sudo docker image prune -f'"
            }
        }
    }
}
        
    }

    post {
        always {
            echo "Pipeline finished."
        }
    }
}