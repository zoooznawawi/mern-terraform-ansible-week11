terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

################
# Variables
################
variable "key_pair_name" {
  description = "Name of an existing EC2 key pair"
  type        = string
}

variable "ami_id" {
  description = "AMI ID to launch the EC2 instance"
  type        = string
}

variable "frontend_bucket" {
  description = "Name for the S3 bucket serving frontend"
  type        = string
}

variable "media_bucket" {
  description = "Name for the S3 bucket for media uploads"
  type        = string
}

################
# Security Group
################
resource "aws_security_group" "app_sg" {
  name        = "mern-app-sg"
  description = "Allow SSH, HTTP, app ports"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
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

################
# EC2 Instance
################
resource "aws_instance" "backend" {
  ami                    = var.ami_id
  instance_type          = "t3.micro"
  key_name               = var.key_pair_name
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  user_data = file("${path.module}/user-data.sh")

  tags = {
    Name = "mern-backend"
  }
}

################
# Frontend S3 Bucket (public)
################
resource "aws_s3_bucket" "frontend" {
  bucket = var.frontend_bucket
  acl    = "public-read"
}

resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket                  = aws_s3_bucket.frontend.id
  block_public_policy     = false
  block_public_acls       = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "frontend_policy" {
  bucket = aws_s3_bucket.frontend.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.frontend.arn}/*"
      }
    ]
  })
}

################
# Media S3 Bucket (private)
################
resource "aws_s3_bucket" "media" {
  bucket = var.media_bucket
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "media" {
  bucket                  = aws_s3_bucket.media.id
  block_public_policy     = true
  block_public_acls       = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

################
# IAM user for media uploads
################
resource "aws_iam_user" "media_uploader" {
  name = "media-uploader"
}

resource "aws_iam_user_policy" "media_uploader_policy" {
  name   = "media-uploader-s3-policy"
  user   = aws_iam_user.media_uploader.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:PutObject","s3:GetObject","s3:DeleteObject"]
        Resource = "${aws_s3_bucket.media.arn}/*"
      }
    ]
  })
}

resource "aws_iam_access_key" "media_uploader_key" {
  user = aws_iam_user.media_uploader.name
}

################
# Outputs
################
output "frontend_bucket" {
  value = aws_s3_bucket.frontend.bucket
}

output "media_bucket" {
  value = aws_s3_bucket.media.bucket
}

output "instance_ip" {
  value = aws_instance.backend.public_ip
}

output "media_uploader_access_key" {
  value = aws_iam_access_key.media_uploader_key.id
}

output "media_uploader_secret_key" {
  value     = aws_iam_access_key.media_uploader_key.secret
  sensitive = true
}
