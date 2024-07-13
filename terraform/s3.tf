# ====================
# S3 bucket
# ====================
resource "aws_s3_bucket" "unimarket-bucket" {
	bucket = "unimarket-bucket-smpkq7cbjadd399cas"
	tags = {
		Name = "unimarket-bucket"
	}
}

#パブリックアクセスを全て許可
resource "aws_s3_bucket_public_access_block" "unimarket-bucket" {
	bucket                  = aws_s3_bucket.unimarket-bucket.id
	block_public_acls       = false
	block_public_policy     = false
	ignore_public_acls      = false
	restrict_public_buckets = false
}

# サーバー側の暗号化設定
resource "aws_s3_bucket_server_side_encryption_configuration" "higa-encryption" {
	bucket = aws_s3_bucket.unimarket-bucket.id
	rule {
		apply_server_side_encryption_by_default {
		sse_algorithm = "AES256"
		}
	}
}
