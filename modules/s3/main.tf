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
resource "aws_s3_object" "incoming" {
  bucket = aws_s3_bucket.this.id
  key    = "incoming/"
}

resource "aws_s3_object" "archive" {
  bucket = aws_s3_bucket.this.id
  key    = "archive/"
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
    filter_prefix       = "incoming/"
  }

  depends_on = [
    aws_lambda_permission.allow_s3
  ]
}
