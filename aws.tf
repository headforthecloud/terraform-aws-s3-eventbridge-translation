provider "aws" {
  default_tags {
    tags = {
      iac_tool = "terraform"
      iac_repo = "terraform-aws-s3-eventbridge-translation"
    }
  }
}


terraform {
  backend "s3" {
    # Replace the values below with your own specific details.
    region         = "eu-west-1"
    encrypt        = true
  }
}
