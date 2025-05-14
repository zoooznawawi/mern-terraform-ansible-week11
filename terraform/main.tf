provider "aws" {
  region = "us-east-1"
}

# Security group
resource "aws_security_group" "app_sg" {
  name        = "mern-app-sg"
  description = "Allow SSH, HTTP, and App port"

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
  ingress {
    from_port   = 5000
    to_port     = 5000
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

# EC2 Instance for backend
resource "aws_instance" "backend" {
  ami                    = var.ami_id
  instance_type          = "t3.micro"
  key_name               = var.key_pair_name
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  tags = {
    Name = "mern-backend-server"
  }
}

# S3 bucket for frontend (static site)
resource "aws_s3_bucket" "frontend" {
  bucket = var.frontend_bucket
  acl    = "public-read"
  website {
    index_document = "index.html"
  }
}

# S3 bucket for media uploads
resource "aws_s3_bucket" "media" {
  bucket = var.media_bucket
  acl    = "private"
}

# IAM user for media uploads
resource "aws_iam_user" "media_uploader" {
  name = "media-uploader"
}
resource "aws_iam_access_key" "media_uploader_key" {
  user = aws_iam_user.media_uploader.name
}

# (You can add IAM policies/policy attachments here if needed)
