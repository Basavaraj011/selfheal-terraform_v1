output "client_vpn_endpoint_id" {
  description = "Client VPN endpoint ID"
  value       = aws_ec2_client_vpn_endpoint.this.id
}

output "client_vpn_security_group_id" {
  description = "Security group used by Client VPN"
  value       = aws_security_group.client_vpn.id
}