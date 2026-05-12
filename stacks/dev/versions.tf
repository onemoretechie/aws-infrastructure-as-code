terraform {
  required_version = ">= 1.9.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # After running `bootstrap/`, replace this block with the snippet from its `backend_config_snippet` output:
  #
  # backend "s3" {
  #   bucket         = "<your-state-bucket>"
  #   key            = "stacks/dev/terraform.tfstate"
  #   region         = "ap-south-1"
  #   dynamodb_table = "terraform-state-lock"
  #   encrypt        = true
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "aws-infrastructure-as-code"
      Environment = "dev"
      ManagedBy   = "terraform"
    }
  }
}
