############################
# S3 Bucket
############################
resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
  force_destroy = true
}

############################
# Folder placeholders
############################
resource "aws_s3_object" "tenant_a_root" {
  bucket = aws_s3_bucket.this.id
  key    = "tenants/tenant-a/"
}

resource "aws_s3_object" "tenant_a_config" {
  bucket = aws_s3_bucket.this.id
  key    = "tenants/tenant-a/config/"
}

resource "aws_s3_object" "tenant_a_incoming" {
  bucket = aws_s3_bucket.this.id
  key    = "tenants/tenant-a/incoming/"
}

resource "aws_s3_object" "tenant_a_archive" {
  bucket = aws_s3_bucket.this.id
  key    = "tenants/tenant-a/archive/"
}

############################
# Allow S3 to invoke Lambda
############################
resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.this.arn
}

############################
# S3 → Lambda notification
# (ONLY incoming/)
############################
resource "aws_s3_bucket_notification" "trigger" {
  bucket = aws_s3_bucket.this.id

  lambda_function {
    lambda_function_arn = var.lambda_arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [
    aws_lambda_permission.allow_s3
  ]
}
