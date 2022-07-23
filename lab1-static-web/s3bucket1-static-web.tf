resource "aws_s3_bucket" "s3web1" {
  bucket = "website-4637585292"
}

// Static website need public access permissions
resource "aws_s3_bucket_acl" "s3web1acl" {
  bucket = aws_s3_bucket.s3web1.id
  acl    = "public-read"
}

// This part includes only configuration and doesnt upload any file
resource "aws_s3_bucket_website_configuration" "s3web1config" {
  bucket = aws_s3_bucket.s3web1.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

  routing_rule {
    condition {
      key_prefix_equals = "docs/"
    }
    redirect {
      replace_key_prefix_with = "documents/"
    }
  }
}


# Printing S3 Web URL
output "s3web1url" {
  value = aws_s3_bucket.s3web1.bucket_regional_domain_name
}