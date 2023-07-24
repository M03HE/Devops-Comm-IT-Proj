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

resource "aws_s3_object" "object" {
  bucket = "commit-project-ilan-moshe"
  key    = "lambda_function.zip"
  source = "lambda_function.zip"
  depends_on = [aws_s3_bucket.commit_project]
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
  s3_bucket        = "commit-project-ilan-moshe"
  s3_key           = "lambda_function.zip"

  layers = [
    aws_lambda_layer_version.lambda_layer.arn,
  ]
  depends_on = [aws_s3_object.object, aws_lambda_layer_version.lambda_layer]
}

resource "aws_lambda_layer_version" "lambda_layer" {
  filename   = "python2.zip"
  layer_name = "project_layer"
  compatible_runtimes = ["python3.10", "python3.9", "python3.8", "python3.7"]
  compatible_architectures = ["x86_64", "arm64"]
}


