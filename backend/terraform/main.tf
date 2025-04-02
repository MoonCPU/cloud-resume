terraform {
   required_providers {
     aws = {
       source  = "hashicorp/aws"
       version = "5.92.0"
     }
   }

  backend "s3" {}
 }
 
 provider "aws" {
   region = var.aws_region
 }

// 1 - create the dynamodb table

resource "aws_dynamodb_table" "visitor_count" {
  name           = var.aws_dynamodb_table_name
  billing_mode   = "PAY_PER_REQUEST" 
  
  hash_key       = "id"  
  
  attribute {
    name = "id"
    type = "S"  
  }

  tags = {
    Name = "VisitorCountTable"
  }
}

// 2 - upload the python script as a lambda function

# configure permission for lambda
resource "aws_iam_role" "lambda_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logs_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# attach policy to allow lambda to write to dynamo
resource "aws_iam_policy_attachment" "lambda_dynamodb_policy" {
  name       = "lambda_dynamodb_policy_attachment"
  roles      = [aws_iam_role.lambda_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

# policy for logging in cloudwatch
resource "aws_iam_policy_attachment" "lambda_logging" {
  name       = "lambda_logging_attachment"
  roles      = [aws_iam_role.lambda_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# package the python script and dependencies
data "archive_file" "lambda_package" {
  type        = "zip"
  source_dir  = "${path.module}/../package"
  output_path = "${path.module}/../lambda_function.zip"
}

resource "aws_lambda_function" "visitor_counter_lambda" {
  function_name = "visitor_counter"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.13"

  filename         = data.archive_file.lambda_package.output_path
  source_code_hash = data.archive_file.lambda_package.output_base64sha256

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.visitor_count.name
    }
  }
}

// 3 - set up the endpoints to lambda using api gateway

# grants API Gateway permission to invoke the Lambda function
resource "aws_lambda_permission" "allow_api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.visitor_counter_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.visitor_counter_api.execution_arn}/*/POST/count"

#     lifecycle {
#     ignore_changes = [source_arn]
#   }
}

# creates an API Gateway instance for the visitor counter service
resource "aws_api_gateway_rest_api" "visitor_counter_api" {
    name        = "visitor_counter_api"
    description = "API for visitor counter"
    }

# this creates a resource inside the API Gateway "visitor_counter_api" and creates the endpoint "/count"
resource "aws_api_gateway_resource" "count_resource" {
    rest_api_id = aws_api_gateway_rest_api.visitor_counter_api.id
    parent_id   = aws_api_gateway_rest_api.visitor_counter_api.root_resource_id
    path_part   = "count"
}

# defines a POST method for the "/count" resource
resource "aws_api_gateway_method" "count_post" {
    rest_api_id   = aws_api_gateway_rest_api.visitor_counter_api.id
    resource_id   = aws_api_gateway_resource.count_resource.id
    http_method   = "POST"
    authorization = "NONE"
}

# links the API Gateway's POST method to the Lambda function as an AWS_PROXY integration
resource "aws_api_gateway_integration" "count_post_integration" {
    rest_api_id             = aws_api_gateway_rest_api.visitor_counter_api.id
    resource_id             = aws_api_gateway_resource.count_resource.id
    http_method             = aws_api_gateway_method.count_post.http_method
    integration_http_method = "POST"
    type                    = "AWS_PROXY"
    uri                     = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${aws_lambda_function.visitor_counter_lambda.arn}/invocations"
}

# deploys the api gateway configuration by creating a deployment
resource "aws_api_gateway_deployment" "visitor_counter_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.visitor_counter_api.id

    depends_on = [
        aws_api_gateway_integration.count_post_integration,
        aws_lambda_permission.allow_api_gateway
    ]

    # redeploys the API when there are changes.
    triggers = {
        redeployment = sha1(jsonencode(aws_api_gateway_rest_api.visitor_counter_api.body))
    }
    # terraform creates a new deployment first before destroying the old one.
    lifecycle {
        create_before_destroy = true
    }
}

# creates a stage for the API Gateway, making the deployment accessible at "/prod"
resource "aws_api_gateway_stage" "visitor_counter_api_stage" {
  deployment_id = aws_api_gateway_deployment.visitor_counter_api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.visitor_counter_api.id
  stage_name    = "prod"

    depends_on = [
    aws_lambda_permission.allow_api_gateway
  ]
}

output "api_gateway_endpoint" {
  value = "${aws_api_gateway_deployment.visitor_counter_api_deployment.invoke_url}${aws_api_gateway_resource.count_resource.path_part}"
}