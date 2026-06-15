# -----------------------------------
# IAM User
# -----------------------------------
resource "aws_iam_user" "post_pr_action" {
  name = "post-pr-action-${var.resource_suffix}"
}

# -----------------------------------
# Inline Policy (Invoke Lambda)
# -----------------------------------
resource "aws_iam_user_policy" "post_pr_action_lambda_invoke" {
  name = "post-pr-action-lambda-invoke-${var.resource_suffix}"
  user = aws_iam_user.post_pr_action.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "lambda:InvokeFunction"
        ]
        Resource = var.post_pr_lambda_arn
      }
    ]
  })
}

# -----------------------------------
# Access Keys (for external systems)
# -----------------------------------
resource "aws_iam_access_key" "post_pr_action_key" {
  user = aws_iam_user.post_pr_action.name
}