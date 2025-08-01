pipeline {
    agent any
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
        // Add test, build, and deploy stages as needed
    }
}
