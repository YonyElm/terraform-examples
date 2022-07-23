terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
      configuration_aliases = [aws.main, aws.peer] # Used when multiple providers exist
    }
  }

  required_version = ">= 0.14.9"
}

# Creating first AWS config
provider "aws" {
  profile = "default"
  region  = "us-west-2"
  alias   = "main"
}

data "aws_availability_zones" "available1" {
  provider  = aws.main
  state     = "available"
}

# Creating second AWS config
provider "aws" {
  profile = "default"
  region  = "us-west-2"
  alias   = "peer"
  # Accepter's credentials.
}

data "aws_availability_zones" "available2" {
  provider  = aws.peer
  state     = "available"
}