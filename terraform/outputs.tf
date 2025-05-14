output "instance_ip" {
  description = "Public IP of backend EC2"
  value       = aws_instance.backend.public_ip
}

output "frontend_bucket" {
  description = "Frontend S3 bucket name"
  value       = aws_s3_bucket.frontend.bucket
}

output "media_bucket" {
  description = "Media uploads S3 bucket name"
  value       = aws_s3_bucket.media.bucket
}

output "media_uploader_access_key" {
  description = "Access key for media-uploader user"
  value       = aws_iam_access_key.media_uploader_key.id
}
output "media_uploader_secret_key" {
  description = "Secret key for media-uploader user"
  value       = aws_iam_access_key.media_uploader_key.secret
  sensitive   = true
}
