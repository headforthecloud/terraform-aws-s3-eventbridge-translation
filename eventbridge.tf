resource "aws_cloudwatch_event_rule" "s3_bucket_cloudtrail_event_rule" {
  name        = "test-bucket-cloudtrail-event-rule"
  description = "Rule to trigger eventbridge on PutObject to test bucket via Cloudtrail"

  event_pattern = jsonencode(
    {
      "source" : ["aws.s3"],
      "detail-type" : ["AWS API Call via CloudTrail"],
      "detail" : {
        "eventSource" : ["s3.amazonaws.com"],
        "eventName" : ["PutObject"],
        "requestParameters" : {
          "bucketName" : [aws_s3_bucket.s3_bucket.id]
        }
      }
    }
  )
}

resource "aws_cloudwatch_event_rule" "s3_bucket_notification_event_rule" {
  name        = "test-bucket-notification-event-rule"
  description = "Rule to trigger eventbridge on PutObject to test bucket via Bucket"

  event_pattern = jsonencode(
    {
      "source": ["aws.s3"],
      "detail-type": ["Object Access Tier Changed", "Object ACL Updated", "Object Created", "Object Deleted", "Object Restore Completed", "Object Restore Expired", "Object Restore Initiated", "Object Storage Class Changed", "Object Tags Added", "Object Tags Deleted"],
      "detail": {
        "bucket": {
          "name": ["264044803517-eu-west-1-eventbridge-translation-bucket"]
        }
      }
    }
  )
}

resource "aws_cloudwatch_event_target" "cloudtrail_lambda_writer" {
  rule = aws_cloudwatch_event_rule.s3_bucket_cloudtrail_event_rule.name
  arn  = aws_lambda_function.eventdump_function.arn
}

resource "aws_cloudwatch_event_target" "notification_lambda_writer" {
  rule = aws_cloudwatch_event_rule.s3_bucket_notification_event_rule.name
  arn  = aws_lambda_function.eventdump_function.arn
}

resource "aws_lambda_permission" "eventbridge_invoke_lambda" {
    statement_id  = "AllowExecutionFromS3CloudtrailEventbridge"
    action        = "lambda:InvokeFunction"
    function_name = aws_lambda_function.eventdump_function.function_name
    principal     = "events.amazonaws.com"
    source_arn    = aws_cloudwatch_event_rule.s3_bucket_cloudtrail_event_rule.arn
}

resource "aws_lambda_permission" "eventbridge_notification_invoke_lambda" {
    statement_id  = "AllowExecutionFromS3NotificationEventbridge"
    action        = "lambda:InvokeFunction"
    function_name = aws_lambda_function.eventdump_function.function_name
    principal     = "events.amazonaws.com"
    source_arn    = aws_cloudwatch_event_rule.s3_bucket_notification_event_rule.arn
}


