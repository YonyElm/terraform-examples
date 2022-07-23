/*
    Upoading files to S3
*/

resource "aws_s3_bucket_object" "index" {
  bucket = aws_s3_bucket.s3web1.bucket
  key    = "index.html"
  source = "./index.html"
  acl = "public-read"       // internet access
  content_type="text/html"
}

resource "aws_s3_bucket_object" "error" {
  bucket = aws_s3_bucket.s3web1.bucket
  key    = "error.html"
  source = "./error.html"
  acl = "public-read"       // internet access
  content_type="text/html"
}

resource "aws_s3_bucket_object" "styles" {
  bucket = aws_s3_bucket.s3web1.bucket
  key    = "styles.css"
  source = "./styles.css"
  acl = "public-read"       // internet access
  content_type="text/css"
}