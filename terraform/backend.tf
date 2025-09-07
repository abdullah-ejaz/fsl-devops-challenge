terraform {
  backend "s3" {
    bucket = "fsl-devops-terraform-bucket"
    key    = "infra.tfstate"
    region = "us-east-1"    
  }
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.100.0"
    }
  }
}

provider "aws" {
 region = var.aws_region
}