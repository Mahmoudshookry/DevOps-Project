pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID     = credentials('AWS-Credinitial')   // Correct credentials name
        AWS_SECRET_ACCESS_KEY = credentials('AWS-Credinitial')
        GITHUB_TOKEN          = credentials('github-token')
        DOCKER_IMAGE          = "m3bdlkawy/depi-project"
    }

    options {
        retry(1)
        timestamps()
    }

    stages {
        stage('Clone Repository') {
            steps {
                git credentialsId: 'github-token', branch: 'master', url: 'https://github.com/Mahmoudshookry/DevOps-Project.git'
            }
        }


        stage('Run Ansible Playbook for Monitoring Stack Deployment') {
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'private-key', keyFileVariable: 'SSH_KEY_PATH', usernameVariable: 'SSH_USER')]) {
                    dir('ansible') {
                        script {
                            sh """
                            ansible-playbook -i inventory_aws_ec2.yaml monitoring-playbook.yml \
                            --private-key $SSH_KEY_PATH \
                            -u $SSH_USER
                            """
                        }
                    }
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
