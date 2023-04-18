resource "aws_s3_bucket" "s3_bucket" {
    bucket        = "${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}-eventbridge-translation-bucket"
    force_destroy = true
}

resource "aws_s3_bucket_acl" "bucket_acl" {
    bucket = aws_s3_bucket.s3_bucket.id
    acl = "private"
}

resource "aws_s3_bucket_public_access_block" "bucket_public_block" {
    bucket = aws_s3_bucket.s3_bucket.id

    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
}

resource "aws_s3_bucket_notification" "bucket_notification" {
    bucket      = aws_s3_bucket.s3_bucket.id
    eventbridge = true

  lambda_function {
    lambda_function_arn = aws_lambda_function.eventdump_function.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [ 
        aws_lambda_function.eventdump_function,
        aws_lambda_permission.eventbridge_notification_invoke_lambda
    ]
}

resource "aws_lambda_permission" "allow_bucket" {
    statement_id  = "AllowExecutionFromS3Notification"
    action        = "lambda:InvokeFunction"
    function_name = aws_lambda_function.eventdump_function.arn
    principal     = "s3.amazonaws.com"
    source_arn    = aws_s3_bucket.s3_bucket.arn
}