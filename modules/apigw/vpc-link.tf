resource "aws_apigatewayv2_vpc_link" "this" {
  name               = "vpclink-${var.resource_suffix}"
  subnet_ids         = var.subnet_ids
  security_group_ids = [var.security_group_id]
}
