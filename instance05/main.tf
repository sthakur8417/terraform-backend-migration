provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "my_ec2" {
  ami="ami-01816d07b1128cd2d"
  instance_type="t2.micro"
} 
