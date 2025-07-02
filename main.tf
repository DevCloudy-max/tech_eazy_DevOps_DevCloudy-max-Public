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
  ami           = var.AMI_img_Id
  instance_type = var.instance_type

  tags = {
    Name  = "EC2-${var.stage}"
    stage = var.stage
  }


  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

  user_data = base64encode(templatefile("scripts/install_app.sh", {
    REPO_URL              = var.github_repo_url,
    STOP_INSTANCE         = var.stop_after,
    S3_BUCKET_NAME        = local.final_bucket_name,
    AWS_REGION_FOR_SCRIPT = var.region


  }))

}
resource "random_string" "bucket_suffix" {
  length  = 6
  upper   = false
  special = false
}

locals {
  final_bucket_name = "${var.s3_bucket_prefix}-${random_string.bucket_suffix.result}"
}

resource "aws_s3_bucket" "logs_bucket" {
  bucket        = local.final_bucket_name
  force_destroy = var.delete_S3_bucket
}

resource "aws_s3_bucket_lifecycle_configuration" "log_cleanup" {

  bucket = aws_s3_bucket.logs_bucket.id

  rule {
    id     = "delete-old-logs"
    status = "Enabled"

    expiration {
      days = 7
    }

    filter {
      prefix = "logs/"
    }
  }
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
  ingress {
    from_port   = 22
    to_port     = 22
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



# Define EC2 Trust Policy
data "aws_iam_policy_document" "assume_ec2" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}


#Role A: Read-Only Role for S3

resource "aws_iam_role" "read_only_role" {
  name               = "read-only-role"
  assume_role_policy = data.aws_iam_policy_document.assume_ec2.json
}

resource "aws_iam_role_policy" "read_only_policy" {
  name = "read-only-policy"
  role = aws_iam_role.read_only_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = ["s3:GetObject", "s3:ListBucket"],
        Resource = [
          "arn:aws:s3:::${local.final_bucket_name}",
          "arn:aws:s3:::${local.final_bucket_name}/*"
        ]
      }
    ]
  })
}


# Role B: Write-Only Role for S3
resource "aws_iam_role" "write_only_role" {
  name               = "write-only-role"
  assume_role_policy = data.aws_iam_policy_document.assume_ec2.json
}

resource "aws_iam_role_policy" "write_only_policy" {
  name = "write-only-policy"
  role = aws_iam_role.write_only_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["s3:PutObject"],
        Resource = "arn:aws:s3:::${local.final_bucket_name}/*"
      }
    ]
  })
}

# Attach Role B to EC2
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2-write-only-profile"
  role = aws_iam_role.write_only_role.name
}
