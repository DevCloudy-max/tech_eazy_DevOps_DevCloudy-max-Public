terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
}


resource "aws_instance" "ec2_instance" {
  ami           = "ami-0d03cb826412c6b0f"
  instance_type = var.instance_type

  tags = {
    Name  = "EC2-${var.stage}"
    stage = var.stage
  }


  user_data = file("scripts/install_app.sh")
}

data "aws_vpc" "default" {
  default = true
}
resource "aws_security_group" "web_sg" {
  name        = "web-access-${var.stage}"
  description = "Allow HTTP access"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}