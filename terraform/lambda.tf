resource "aws_iam_role" "lambda" {
  name = "DynamoDBRole"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : "lambda.amazonaws.com"
        },
        "Effect" : "Allow",
        "Sid" : ""
      }
    ]
  })
}

resource "aws_iam_policy" "lambdaPolicyIAM" {
  name        = "aws_iam_policy_for_terraform_aws_lambda_role"
  path        = "/"
  description = "IAM policy for terraform aws_lambda_role"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [{
      "Action" : [
        "dynamodb:BatchGetItem",
        "dynamodb:GetItem",
        "dynamodb:Query",
        "dynamodb:Scan",
        "dynamodb:BatchWriteItem",
        "dynamodb:PutItem",
        "dynamodb:UpdateItem"
      ],
      "Resource" : "arn:aws:dynamodb:*",
      "Effect" : "Allow"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambdaPolicyIAMAttachment" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambdaPolicyIAM.arn
}

data "archive_file" "lambda_write" {
  type        = "zip"
  source_dir  = "${path.module}/write_to_guestbook"
  output_path = "${path.module}/write_to_guestbook.zip"
}

resource "aws_lambda_function" "lambda_write" {
  filename      = data.archive_file.lambda_write.output_path
  function_name = var.write_function_name
  role          = aws_iam_role.lambda.arn
  handler       = "write_to_guestbook.lambda_handler"
  runtime       = "python3.9"
  depends_on = [
    aws_iam_role_policy_attachment.lambdaPolicyIAMAttachment
  ]
}

data "archive_file" "lambda_read" {
  type        = "zip"
  source_dir  = "${path.module}/read_from_guestbook"
  output_path = "${path.module}/read_from_guestbook.zip"
}

resource "aws_lambda_function" "lambda_read" {
  filename      = data.archive_file.lambda_read.output_path
  function_name = var.read_function_name
  role          = aws_iam_role.lambda.arn
  handler       = "retreive_database_entries.lambda_handler"
  runtime       = "python3.9"
  depends_on = [
    aws_iam_role_policy_attachment.lambdaPolicyIAMAttachment
  ]
}