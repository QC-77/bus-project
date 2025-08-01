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
                sh 'pip install --upgrade pip'
                sh 'pip install black flake8 boto3 requests'
            }
        }
        stage('Lint Python') {
            steps {
                sh 'black --check lambda_nyc_extractor/lambda_function.py'
                sh 'flake8 lambda_nyc_extractor/lambda_function.py --max-line-length=88'
            }
        }
        stage('Lint Terraform') {
            steps {
                sh 'terraform fmt -check'
                sh 'terraform validate'
            }
        }
        // Add test, build, and deploy stages as needed
    }
}
