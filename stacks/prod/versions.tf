terraform {
  required_version = ">= 1.9.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }

  # After running `bootstrap/`, replace this block with the snippet from its `backend_config_snippet` output:
  #
  # backend "s3" {
  #   bucket         = "<your-state-bucket>"
  #   key            = "stacks/prod/terraform.tfstate"
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
      Environment = "prod"
      ManagedBy   = "terraform"
    }
  }
}

# CloudFront + its ACM certificate must live in us-east-1.
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"

  default_tags {
    tags = {
      Project     = "aws-infrastructure-as-code"
      Environment = "prod"
      ManagedBy   = "terraform"
    }
  }
}
