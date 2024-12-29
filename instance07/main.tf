terraform {
  backend "s3" {
    bucket         = "s3statebackend84170703"
    key            = "dev-machines/instance-07/terraform.tfstate"
    region         = "us-east-1"    # Replace with your AWS region
    dynamodb_table = "state-lock"
    encrypt        = true
  }
}







provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "my_ec2" {
  ami="ami-01816d07b1128cd2d"
  instance_type="t2.micro"
} 
