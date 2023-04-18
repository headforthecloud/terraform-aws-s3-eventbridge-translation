data "archive_file" "lambda_function_zip" {
    type = "zip"
    source_file = "source/eventbridge_transform/lambda_function.py"
    output_path = "source/eventbridge_transform/lambda.zip"
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name = "/aws/lambda/${aws_lambda_function.eventdump_function.function_name}"
  retention_in_days = 1
}


resource "aws_lambda_function" "eventdump_function" {
    function_name    = "eventbridge_transformer"
    role             = aws_iam_role.lambda_execution_role.arn
    description      = "Dump event received by lambda to cloudwatch logs"
    filename         = data.archive_file.lambda_function_zip.output_path
    source_code_hash = data.archive_file.lambda_function_zip.output_base64sha256
    handler          = "lambda_function.lambda_handler"
    runtime          = "python3.9"
    environment {
      variables = {
        LOG_LEVEL = "DEBUG"
      }
    }
}
