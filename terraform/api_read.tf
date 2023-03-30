resource "aws_api_gateway_rest_api" "guestbook_read" {
  name        = "guestbook_read"
  description = "API to retreive data from DynamoDB table"
}

resource "aws_api_gateway_resource" "guestbook_read" {
  rest_api_id = aws_api_gateway_rest_api.guestbook_read.id
  parent_id   = aws_api_gateway_rest_api.guestbook_read.root_resource_id
  path_part   = "read_from_database"
}

resource "aws_api_gateway_method" "options_read" {
  rest_api_id   = aws_api_gateway_rest_api.guestbook_read.id
  resource_id   = aws_api_gateway_resource.guestbook_read.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "options_read" {
  rest_api_id = aws_api_gateway_rest_api.guestbook_read.id
  resource_id = aws_api_gateway_resource.guestbook_read.id
  http_method = aws_api_gateway_method.options_read.http_method
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
    aws_api_gateway_method.options_read
  ]
}

resource "aws_api_gateway_integration" "options_read" {
  rest_api_id = aws_api_gateway_rest_api.guestbook_read.id
  resource_id = aws_api_gateway_resource.guestbook_read.id
  http_method = aws_api_gateway_method.options_read.http_method
  type        = "MOCK"
  request_templates = {
    "application/json" = <<EOF
            {
                "statusCode" : 200
            }
        EOF
  }
}

resource "aws_api_gateway_integration_response" "options_read" {
  rest_api_id = aws_api_gateway_rest_api.guestbook_read.id
  resource_id = aws_api_gateway_resource.guestbook_read.id
  http_method = aws_api_gateway_method.options_read.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,GET'"
  }
  depends_on = [
    aws_api_gateway_method_response.options_read
  ]
}

resource "aws_api_gateway_method" "get" {
  rest_api_id   = aws_api_gateway_rest_api.guestbook_read.id
  resource_id   = aws_api_gateway_resource.guestbook_read.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "get" {
  rest_api_id = aws_api_gateway_rest_api.guestbook_read.id
  resource_id = aws_api_gateway_resource.guestbook_read.id
  http_method = aws_api_gateway_method.get.http_method
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
    aws_api_gateway_method.get
  ]
}

resource "aws_api_gateway_integration" "integration_read" {
  rest_api_id             = aws_api_gateway_rest_api.guestbook_read.id
  resource_id             = aws_api_gateway_resource.guestbook_read.id
  http_method             = aws_api_gateway_method.get.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.lambda_read.invoke_arn
  depends_on = [
    aws_api_gateway_method.get
  ]
}

resource "aws_api_gateway_deployment" "deployment_read" {
  rest_api_id = aws_api_gateway_rest_api.guestbook_read.id
  stage_name  = "prod"
  depends_on = [
    aws_api_gateway_integration.integration_read
  ]
}

resource "aws_lambda_permission" "api_gateway_read" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_read.function_name
  principal     = "apigateway.amazonaws.com"
}