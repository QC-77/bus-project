pipeline {
    agent any
    environment {
        AWS_DEFAULT_REGION = 'us-east-1'
    }
    parameters {
        booleanParam(
            name: 'DESTROY_INFRA',
            defaultValue: false,
            description: 'Check this to destroy all AWS resources after build (safe manual cleanup)'
        )
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
                // Clean package folder (if it exists)
                bat 'if exist lambda_package rmdir /s /q lambda_package'
                bat 'mkdir lambda_package'
                // Zip ALL content of lambda_nyc_extractor for Lambda deployment
                bat 'powershell -Command "Compress-Archive -Path lambda_nyc_extractor\\* -DestinationPath lambda_package\\lambda_nyc_extractor_package.zip
