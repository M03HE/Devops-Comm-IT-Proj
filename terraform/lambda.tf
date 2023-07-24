resource "aws_iam_role" "lambda_role" {
  name = "lambda-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda_policy" {
  name = "lambda-policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "dynamodb:PutItem",
        "ssm:GetParameter",
        "ssm:GetParameters",
        "ssm:DescribeParameters",
        "s3:GetObject",
        "s3:PutObject",
        "s3:PutObjectAcl",
        "s3:PutObjectTagging",
        "s3:PutObjectVersionAcl",
        "s3:PutObjectVersionTagging"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "lambda_policy_attachment" {
  name       = "lambda-policy-attachment"
  roles      = [aws_iam_role.lambda_role.name]
  policy_arn = aws_iam_policy.lambda_policy.arn
}

resource "aws_lambda_function" "my_lambda_function" {
  function_name    = "token-dynamodb-parameter"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.10"
  timeout          = 10
  memory_size      = 128
  # Uncomment the following two lines and provide the appropriate values
  # s3_bucket        = "moshedabush-devops"
  s3_bucket        = "commit-project-llan-moshe"
  s3_key           = "lambda_function.zip"

  layers = [
    "arn:aws:lambda:eu-central-1:164980749225:layer:jwt:4"
    # "arn:aws:lambda:eu-west-1:169244118978:layer:jwt:3"
  ]
}

# Data resource to zip a folder
# data "archive_file" "my_folder_archive" {
#   type        = "zip"
#   source_dir  = "utils"
#   output_path = "utils/jwt.zip"
# }

# # IAM Role for Lambda
# resource "aws_iam_role" "lambda_role" {
#   name = "lambda-role"
#   assume_role_policy = jsonencode({
#     "Version": "2012-10-17",
#     "Statement": [
#       {
#         "Action": "sts:AssumeRole",
#         "Principal": {
#           "Service": "lambda.amazonaws.com"
#         },
#         "Effect": "Allow",
#         "Sid": ""
#       }
#     ]
#   })
# }

# # IAM Policy Attachment
# resource "aws_iam_policy_attachment" "lambda_policy_attachment" {
#   name       = "lambda-policy-attachment"
#   roles      = [aws_iam_role.lambda_role.name]
#   policy_arn = aws_iam_policy.lambda_policy.arn
# }

# # Create the Lambda layer resource using the zipped folder
# resource "aws_lambda_layer_version" "jwt_layer" {
#   layer_name          = "jwt"
#   s3_bucket           = "commit-project"  # Replace with your S3 bucket name
#   s3_key              = data.archive_file.my_folder_archive.output_path  # Use the output path from the data resource

#   compatible_runtimes = ["python3.10"]  # Modify this if you need to support different runtimes
#     depends_on = [
#     aws_lambda_layer_version.jwt_layer
#   ]
# }

# # Lambda Function
# resource "aws_lambda_function" "my_lambda_function" {
#   function_name = "token-dynamodb-parameter-prod"
#   role          = aws_iam_role.lambda_role.arn
#   handler       = "lambda_function.lambda_handler"
#   runtime       = "python3.10"
#   timeout       = 10
#   memory_size   = 128
#   s3_bucket     = "commit-project"
#   s3_key        = "lambda_function-prod.zip"

#   # Use the created Lambda layer in the function
#   layers = [aws_lambda_layer_version.jwt_layer.arn]
#   depends_on = [
#     aws_lambda_layer_version.jwt_layer
#   ]
# }
