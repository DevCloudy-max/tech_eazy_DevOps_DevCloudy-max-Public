terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# STEP 1: Create a key pair and store private key locally
resource "tls_private_key" "ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# --- 🔐 Write-only Key Pair with protection toggle using count ---
resource "aws_key_pair" "generated_key" {
  count      = var.enable_protection ? 1 : 0
  key_name   = "${var.stage}-key"
  public_key = tls_private_key.ec2_key.public_key_openssh
  lifecycle {
    prevent_destroy = true
  }
}

# Fallback when prevent_destroy is false
resource "aws_key_pair" "generated_key_no_protect" {
  count      = var.enable_protection ? 0 : 1
  key_name   = "${var.stage}-key"
  public_key = tls_private_key.ec2_key.public_key_openssh
}

# 📝 Save private key to PEM file
resource "local_file" "private_key" {
  filename        = "${path.module}/${var.stage}-key.pem"
  content         = tls_private_key.ec2_key.private_key_pem
  file_permission = "0400"
}

# --- 🔀 Random S3 bucket name using suffix ---
resource "random_string" "bucket_suffix" {
  length  = 6
  upper   = false
  special = false
}

locals {
  final_bucket_name = "${var.s3_bucket_prefix}-${random_string.bucket_suffix.result}"
}

# --- 🔐 IAM ROLES and POLICIES ---

data "aws_iam_policy_document" "assume_ec2" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# Read-only role
resource "aws_iam_role" "read_only_role" {
  name               = "read-only-role"
  assume_role_policy = data.aws_iam_policy_document.assume_ec2.json
}

resource "aws_iam_role_policy" "read_only_policy" {
  name = "read-only-policy"
  role = aws_iam_role.read_only_role.id

  policy = templatefile("Policies/read_only_policy.tpl.json", {
    bucket_name = local.final_bucket_name
  })
}

# Write-only role
resource "aws_iam_role" "write_only_role" {
  name               = "write-only-role"
  assume_role_policy = data.aws_iam_policy_document.assume_ec2.json
}

resource "aws_iam_role_policy" "write_only_policy" {
  name = "write-only-policy"
  role = aws_iam_role.write_only_role.id

  policy = templatefile("Policies/write_only_policy.tpl.json", {
    bucket_name = local.final_bucket_name
  })
}

# --- ✅ ec2-write-only-profile with protect toggle ---
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  count = var.enable_protection ? 1 : 0
  name  = "ec2-write-only-profile"
  role  = aws_iam_role.write_only_role.name

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_iam_instance_profile" "ec2_instance_profile_no_protect" {
  count = var.enable_protection ? 0 : 1
  name  = "ec2-write-only-profile"
  role  = aws_iam_role.write_only_role.name
}

# --- ✅ ec2-read-only-profile with protect toggle ---
resource "aws_iam_instance_profile" "read_instance_profile" {
  count = var.enable_protection ? 1 : 0
  name  = "ec2-read-only-profile"
  role  = aws_iam_role.read_only_role.name

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_iam_instance_profile" "read_instance_profile_no_protect" {
  count = var.enable_protection ? 0 : 1
  name  = "ec2-read-only-profile"
  role  = aws_iam_role.read_only_role.name
}

# --- 📦 S3 Bucket ---
resource "aws_s3_bucket" "logs_bucket" {
  bucket        = local.final_bucket_name
  force_destroy = var.delete_S3_bucket
}

# --- 📜 S3 Lifecycle Rule ---
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

# --- 🌐 Networking ---
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

# --- 🚀 Main EC2 Instance ---
resource "aws_instance" "ec2_instance" {
  ami           = var.AMI_img_Id
  instance_type = var.instance_type
  key_name = coalesce(
    try(aws_key_pair.generated_key[0].key_name, null),
    try(aws_key_pair.generated_key_no_protect[0].key_name, null)
  )

  iam_instance_profile = coalesce(
    try(aws_iam_instance_profile.ec2_instance_profile[0].name, null),
    try(aws_iam_instance_profile.ec2_instance_profile_no_protect[0].name, null)
  )

  tags = {
    Name  = "EC2-${var.stage}"
    stage = var.stage
  }

  user_data = base64encode(templatefile("scripts/install_app.sh", {
    REPO_URL              = var.github_repo_url,
    STOP_INSTANCE         = var.stop_after,
    S3_BUCKET_NAME        = local.final_bucket_name,
    AWS_REGION_FOR_SCRIPT = var.region
  }))
}

# --- 🔎 Verifier EC2 Instance ---
resource "aws_instance" "reader_instance" {
  ami           = var.AMI_img_Id
  instance_type = var.instance_type
  depends_on    = [aws_instance.ec2_instance]

  key_name = coalesce(
    try(aws_key_pair.generated_key[0].key_name, null),
    try(aws_key_pair.generated_key_no_protect[0].key_name, null)
  )

  iam_instance_profile = coalesce(
    try(aws_iam_instance_profile.read_instance_profile[0].name, null),
    try(aws_iam_instance_profile.read_instance_profile_no_protect[0].name, null)
  )

  tags = {
    Name = "EC2-ReadOnly-Verifier"
  }

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y awscli
              sleep 120
              aws s3 ls s3://${local.final_bucket_name}/logs/ --region ${var.region} > /var/log/s3-read-check.log 2>&1
              EOF
}
