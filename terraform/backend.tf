terraform {
  backend "s3" {
    
  }
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.100.0"
    }
  }
}

provider "aws" {
  # Configuration options
}