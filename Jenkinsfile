pipeline {
    agent any
    environment {
        AWS_DEFAULT_REGION = 'us-east-1'
    }
    stages {
        // ... (previous stages like Checkout, Install Dependencies, etc.)
        stage('Check Branch') {
            steps {
                bat 'echo Current branch: %GIT_BRANCH%'
                bat 'git branch'
                bat 'git rev-parse --abbrev-ref HEAD'
            }
        }
        stage('Terraform Apply -auto-approve') {
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
