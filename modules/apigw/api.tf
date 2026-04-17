resource "aws_apigatewayv2_api" "this" {
  name          = "apigw-${var.resource_suffix}"
  protocol_type = "HTTP"
}