resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "App_Users"
      depends_on = [
    aws_cognito_user_pool.user_pool,
    aws_cognito_user_pool_client.client
  ]
  dashboard_body = <<EOF
{
  "widgets": [
    {
      "type": "metric",
      "x": 0,
      "y": 0,
      "width": 12,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "AWS/Cognito",
            "SignUpSuccesses",
            "UserPool",
            "${aws_cognito_user_pool.user_pool.id}",
            "UserPoolClient",
            "${aws_cognito_user_pool_client.client.id}",
            {
              "stat": "Sum",
              "region": "eu-west-2",
              "period": 300
            }
          ],
          [
            "AWS/Cognito",
            "SignUpThrottles",
            "UserPool",
            "${aws_cognito_user_pool.user_pool.id}",
            "UserPoolClient",
            "${aws_cognito_user_pool_client.client.id}",
            {
              "stat": "Sum",
              "region": "eu-west-2",
              "period": 300
            }
          ],
          [
            "AWS/Cognito",
            "SignInSuccesses",
            "UserPool",
            "${aws_cognito_user_pool.user_pool.id}",
            "UserPoolClient",
            "${aws_cognito_user_pool_client.client.id}",
            {
              "stat": "Sum",
              "region": "eu-west-2",
              "period": 300
            }
          ],
          [
            "AWS/Cognito",
            "SignInThrottles",
            "UserPool",
            "${aws_cognito_user_pool.user_pool.id}",
            "UserPoolClient",
            "${aws_cognito_user_pool_client.client.id}",
            {
              "stat": "Sum",
              "region": "eu-west-2",
              "period": 300
            }
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "eu-west-2",
        "title": "Cognito Metrics"
      }
    }
  ]
}
EOF
}