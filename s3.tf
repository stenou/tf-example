resource "aws_s3_bucket" "s3" {
  bucket = "stenou-test"
  acl    = "private"

  versioning {
    enabled = true
  }
}