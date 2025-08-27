resource "aws_s3_bucket" "web_assets" {
  bucket = var.bucket_name
  acl    = "private"
  tags = {
    Name        = "3-tier"
    Environment = "production"
    Owner       = "het"
  }

}