# S3 bucket with public ACL and no access logging
resource "aws_s3_bucket" "public_bucket" {
  bucket = "my-public-bucket-test"
  acl    = "public-read" # Violates: S3 Bucket ACL must not allow public READ Access
}

# No access logging enabled
# Violates: Ensure the S3 bucket has access logging enabled

# Public access block disabled
resource "aws_s3_bucket_public_access_block" "public_bucket" {
  bucket                  = aws_s3_bucket.public_bucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Insecure S3 bucket policy with global permissions
resource "aws_s3_bucket_policy" "insecure_policy" {
  bucket = aws_s3_bucket.public_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"] # Violates: global read/write/delete
        Resource = "${aws_s3_bucket.public_bucket.arn}/*"
      }
    ]
  })
}

# Security Group allowing SSH and RDP from anywhere
resource "aws_security_group" "insecure_sg" {
  name = "insecure_sg"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Violates: SSH open to world
  }
  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Violates: RDP open to world
  }
}

# IAM role with wildcard permissions
resource "aws_iam_policy" "wildcard_policy" {
  name = "wildcard_policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "*"
        Resource = "*"
      }
    ]
  })
}

# EC2 instance with public IP
resource "aws_instance" "public_instance" {
  ami           = "ami-123456"
  instance_type = "t2.micro"
  associate_public_ip_address = true # Violates: VM must not have public IP
}

# VPC without flow logs
resource "aws_vpc" "insecure_vpc" {
  cidr_block = "10.0.0.0/16"
}
# No aws_flow_log resource -> Violates: Enable VPC flow logs

# CloudTrail without log file validation
resource "aws_cloudtrail" "insecure_trail" {
  name                          = "insecure-trail"
  s3_bucket_name               = aws_s3_bucket.public_bucket.bucket
  enable_log_file_validation   = false # Violates: Ensure CloudTrail enabled with validation
}