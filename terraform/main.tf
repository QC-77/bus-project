terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "iam" {
  source             = "./modules/iam"
  environment        = var.environment
  s3_bucket_name     = var.s3_bucket_name
  dynamodb_table_arn = module.dynamodb.table_arn
}

module "s3" {
  source      = "./modules/s3"
  bucket_name = var.s3_bucket_name
  environment = var.environment
}

module "dynamodb" {
  source      = "./modules/dynamodb"
  table_name  = var.dynamodb_table_name
  environment = var.environment
}

module "lambda" {
  source              = "./modules/lambda"
  function_name       = var.lambda_function_name
  handler             = var.lambda_handler
  runtime             = var.lambda_runtime
  lambda_package_path = var.lambda_package_path
  s3_bucket           = module.s3.bucket_name
  dynamodb_table      = module.dynamodb.table_name
  environment         = var.environment
  iam_role_arn        = module.iam.lambda_role_arn
}

module "cognito" {
  source      = "./modules/cognito"
  environment = var.environment
}

module "monitoring" {
  source                = "./modules/monitoring"
  lambda_function_name  = module.lambda.lambda_function_name
  sns_topic_name        = var.sns_topic_name
  environment           = var.environment
}

module "api_gateway" {
  source                = "./modules/api_gateway"
  lambda_function       = module.lambda.lambda_function_arn
  lambda_function_name  = module.lambda.lambda_function_name   # <-- this line is needed
  user_pool_arn         = module.cognito.user_pool_arn
  environment           = var.environment
  aws_region            = var.aws_region
}


