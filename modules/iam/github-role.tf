resource "aws_iam_role" "github_actions_role" {
  name = "github-actions-ecr-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",

        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          },
          StringLike = {
            "token.actions.githubusercontent.com:sub" = [
              "repo:darshita-singh/error_handling_system:*",
              "repo:Basavaraj011/pub-workflow-simulator:*",
              "repo:Basavaraj011/error_handling_system_fork:*",
              "repo:Basavaraj011/error_pipeline_demo:*"
            ]
          }
        }
      }
    ]
  })
}

########################################
# ECR Push Policy
########################################
resource "aws_iam_policy" "github_ecr_push" {
  name = "github-ecr-push-policy-selfheal"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecr:GetAuthorizationToken"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage"
        ],
        Resource = "arn:aws:ecr:*:*:repository/selfheal"
      }
    ]
  })
}

# Lambda invoke policy

resource "aws_iam_policy" "github_lambda_invoke" {
  name = "github-lambda-invoke-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "lambda:InvokeFunction"
        ],
        Resource = [
          "arn:aws:lambda:us-east-1:874456856173:function:post-pr-actions-trigger",
          "arn:aws:lambda:us-east-1:874456856173:function:selfheal_retry"
        ]
      }
    ]
  })
}

########################################
# Attach Policy to Role
########################################
resource "aws_iam_role_policy_attachment" "github_ecr_attach" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = aws_iam_policy.github_ecr_push.arn
}

# Attach invoke policy 
resource "aws_iam_role_policy_attachment" "github_lambda_attach" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = aws_iam_policy.github_lambda_invoke.arn
}