pipeline {
    agent any
    environment {
        AWS_DEFAULT_REGION = 'us-east-1' // or your AWS region
    }
    stages {
        // ... previous stages (checkout, lint, etc.)
        stage('Terraform Apply') {
            when {
                branch 'main'
            }
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
