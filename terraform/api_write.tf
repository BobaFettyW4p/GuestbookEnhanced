resource "aws_api_gateway_rest_api" "guestbook_write" {
  name        = "guestbook_write"
  description = "API to write data to write to DynamoDB table"
}

resource "aws_api_gateway_resource" "guestbook_write" {
  rest_api_id = aws_api_gateway_rest_api.guestbook_write.id
  parent_id   = aws_api_gateway_rest_api.guestbook_write.root_resource_id
  path_part   = "write_to_database"
}

resource "aws_api_gateway_method" "options" {
  rest_api_id   = aws_api_gateway_rest_api.guestbook_write.id
  resource_id   = aws_api_gateway_resource.guestbook_write.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "options" {
  rest_api_id = aws_api_gateway_rest_api.guestbook_write.id
  resource_id = aws_api_gateway_resource.guestbook_write.id
  http_method = aws_api_gateway_method.options.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
  depends_on = [
    aws_api_gateway_method.options
  ]
}

resource "aws_api_gateway_integration" "options" {
  rest_api_id = aws_api_gateway_rest_api.guestbook_write.id
  resource_id = aws_api_gateway_resource.guestbook_write.id
  http_method = aws_api_gateway_method.options.http_method
  type        = "MOCK"
  request_templates = {
    "application/json" = <<EOF
            {
                "statusCode" : 200
            }
        EOF
  }
}

resource "aws_api_gateway_integration_response" "options" {
  rest_api_id = aws_api_gateway_rest_api.guestbook_write.id
  resource_id = aws_api_gateway_resource.guestbook_write.id
  http_method = aws_api_gateway_method.options.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,POST'"
  }
  depends_on = [
    aws_api_gateway_method_response.options
  ]
}

resource "aws_api_gateway_method" "post" {
  rest_api_id   = aws_api_gateway_rest_api.guestbook_write.id
  resource_id   = aws_api_gateway_resource.guestbook_write.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "post" {
  rest_api_id = aws_api_gateway_rest_api.guestbook_write.id
  resource_id = aws_api_gateway_resource.guestbook_write.id
  http_method = aws_api_gateway_method.post.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
  depends_on = [
    aws_api_gateway_method.post
  ]
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = aws_api_gateway_rest_api.guestbook_write.id
  resource_id             = aws_api_gateway_resource.guestbook_write.id
  http_method             = aws_api_gateway_method.post.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.lambda_write.invoke_arn
  depends_on = [
    aws_api_gateway_method.post, aws_lambda_function.lambda_write
  ]
}

resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.guestbook_write.id
  stage_name  = "prod"
  depends_on = [
    aws_api_gateway_integration.integration
  ]
}

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_write.function_name
  principal     = "apigateway.amazonaws.com"
}