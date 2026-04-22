# Server certificate (used by VPN endpoint)
resource "aws_acm_certificate" "server" {
  certificate_body  = file(var.server_cert_path)
  private_key       = file(var.server_key_path)
  certificate_chain = file(var.ca_cert_path)
}

# Client root CA (used to authenticate VPN clients)
resource "aws_acm_certificate" "client_ca" {
  certificate_body = file(var.ca_cert_path)
  private_key      = file(var.ca_key_path)
}

# Security group for Client VPN endpoint
resource "aws_security_group" "client_vpn" {
  name   = "client-vpn-sg"
  vpc_id = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Client VPN endpoint
resource "aws_ec2_client_vpn_endpoint" "this" {
  description            = "Selfheal Client VPN"
  server_certificate_arn = aws_acm_certificate.server.arn
  client_cidr_block      = var.client_cidr_block
  vpc_id = var.vpc_id
  
  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = aws_acm_certificate.client_ca.arn
  }

  transport_protocol = "udp"
  vpn_port           = 443
  split_tunnel       = true

  security_group_ids = [aws_security_group.client_vpn.id]

  connection_log_options {
    enabled = false
  }
}

# Associate Client VPN with private subnet
resource "aws_ec2_client_vpn_network_association" "subnet" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.this.id
  subnet_id              = var.private_subnet_id
}

# Authorization rule
resource "aws_ec2_client_vpn_authorization_rule" "allow_vpc" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.this.id
  target_network_cidr    = var.vpc_cidr
  authorize_all_groups   = true
}