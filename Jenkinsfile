
pipeline {
    agent any
    environment {
        AWS_DEFAULT_REGION = 'us-east-1'
    }
    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }
        stage('Install Dependencies') {
            steps {
                bat 'pip install --upgrade pip'
                bat 'pip install black flake8 boto3 requests'
            }
        }
        stage('Build Lambda Package') {
            steps {
                bat 'mkdir lambda_package'
                bat 'powershell Compress-Archive -Path lambda_nyc_extractor\\lambda_function.py -DestinationPath lambda_package\\lambda_nyc_extractor_package.zip -Force'
            }
        }
        stage('Lint Python') {
            steps {
                bat 'black --check lambda_nyc_extractor/lambda_function.py'
                bat 'flake8 lambda_nyc_extractor/lambda_function.py --max-line-length=88'
            }
        }
        stage('Lint Terraform') {
            steps {
                bat 'terraform fmt -check'
                bat 'terraform validate'
            }
        }
        stage('Terraform Apply -auto-approve') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'aws-credentials',
                    usernameVariable: 'AWS_ACCESS_KEY_ID',
                    passwordVariable: 'AWS_SECRET_ACCESS_KEY'
                )]) {
                    bat 'cd terraform && terraform init'
                    bat 'cd terraform && terraform apply -auto-approve'
                }
            }
        }
    }
}
