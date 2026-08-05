pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')
        IMAGE_NAME = 'devadarsh1/ecommerce-app'
        BUILD_TAG = "${BUILD_NUMBER}"
        KUBECONFIG = '/var/lib/jenkins/.kube/config'
    }
	
    triggers {
        githubPush()
     } 



    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${IMAGE_NAME}:${BUILD_TAG} ."
                    sh "docker tag ${IMAGE_NAME}:${BUILD_TAG} ${IMAGE_NAME}:latest"
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    sh "echo \$DOCKERHUB_CREDENTIALS_PSW | docker login -u \$DOCKERHUB_CREDENTIALS_USR --password-stdin"
                    sh "docker push ${IMAGE_NAME}:${BUILD_TAG}"
                    sh "docker push ${IMAGE_NAME}:latest"
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    sh "kubectl --kubeconfig=/var/lib/jenkins/.kube/config set image deployment/ecommerce-deployment ecommerce=${IMAGE_NAME}:${BUILD_TAG}"
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                script {
                    sh "kubectl --kubeconfig=/var/lib/jenkins/.kube/config rollout status deployment/ecommerce-deployment --timeout=60s"
                }
            }
        }
    }

    post {
        failure {
            echo 'Deployment failed. Rolling back...'
            sh 'kubectl --kubeconfig=/var/lib/jenkins/.kube/config rollout undo deployment/ecommerce-deployment'
        }
        always {
            sh 'docker logout'
        }
    }
}

