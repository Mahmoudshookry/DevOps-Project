pipeline {
    agent any

    environment {
        // Set up environment variables for AWS and GitHub
        AWS_ACCESS_KEY_ID     = credentials('AWS-Credinitial')   // AWS Access Key from Jenkins Credentials
        AWS_SECRET_ACCESS_KEY = credentials('AWS-Credinitial')   // AWS Secret Key from Jenkins Credentials
        GITHUB_TOKEN          = credentials('github-token')      // GitHub token for private repository access
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials') // Docker Hub credentials
        DOCKER_IMAGE          = "m3bdlkawy/depi-project" // Docker image name
    }

    options {
        retry(1) // Optional: retry on failures
    }

    stages {
        stage('Clone Repository') {
            steps {
                // Clone the main repository
                git credentialsId: 'github-token', branch: 'master', url: 'https://github.com/Mahmoudshookry/DevOps-Project.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Build the Docker image
                    dockerImage = docker.build("${DOCKER_IMAGE}:${env.BUILD_NUMBER}")
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    // Push the Docker image to Docker Hub
                    docker.withRegistry('https://index.docker.io/v1/', 'dockerhub-credentials') {
                        dockerImage.push("${env.BUILD_NUMBER}")
                        dockerImage.push("latest")
                    }
                }
            }
        }

        stage('Clean Up') {
            steps {
                script {
                    // Optional cleanup, skipping due to permission issues
                    echo "Skipping image removal due to permission issues."
                }
            }
        }

        stage('Checkout Code') {
            steps {
                // Checkout the code from another GitHub repository
                git branch: 'master', credentialsId: 'github-token', url: 'https://github.com/Mahmoudshookry/DevOps-Project.git'
            }
        }

        stage('Terraform Init') {
            steps {
                dir('aws-k8s-terraform') {
                    script {
                        // Initialize Terraform
                        sh 'terraform init'
                    }
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                dir('aws-k8s-terraform') {
                    script {
                        // Apply Terraform to create infrastructure
                        sh 'terraform apply -auto-approve'
                    }
                }
            }
        }

        stage('Wait for EC2 Initialization') {
            steps {
                script {
                    def isReachable = false
                    retry(10) {
                        sleep(time: 30, unit: 'SECONDS')
                        try {
                            // Check if EC2 instance is reachable via SSH
                            sh """
                            ssh -i $SSH_KEY_PATH -o StrictHostKeyChecking=no ubuntu@<EC2_PUBLIC_IP> 'echo EC2 is reachable'
                            """
                            isReachable = true
                        } catch (Exception e) {
                            echo "EC2 not ready yet, retrying..."
                            isReachable = false
                            error "SSH not ready"
                        }
                    }

                    if (!isReachable) {
                        error "EC2 instances are not reachable after multiple retries"
                    }
                }
            }
        }

        stage('Run Ansible Playbook') {
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'private-key', keyFileVariable: 'SSH_KEY_PATH', usernameVariable: 'SSH_USER')]) {
                    dir('ansible') {
                        script {
                            // Run Ansible playbook
                            sh """
                            ansible-playbook -i inventory_aws_ec2.yaml playbook.yml \
                            --private-key $SSH_KEY_PATH \
                            -u $SSH_USER
                            """
                        }
                    }
                }
            }
        }

        stage('Deploy Helm Chart') {
            steps {
                script {
                    // Install or upgrade the Helm release
                    sh """
                    helm upgrade --install my-release ./helm --values ./helm/values.yaml --namespace my-namespace --create-namespace
                    """
                }
            }
        }
    }

    post {
        success {
            echo 'Deployment completed successfully!'
        }
        failure {
            echo 'Deployment failed!'
        }
    }
}
