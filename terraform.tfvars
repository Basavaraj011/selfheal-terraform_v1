region                                = "us-east-1"
vpc_id                                = "vpc-0e9d7670b10ec2ef3"
vpc_cidr                              = "172.31.0.0/16" # For client VPN as destination

create_subnets                        = false

availability_zones                    = ["us-east-1c", "us-east-1d"]


existing_private_subnet_ids           = [
                                        "subnet-01b9f04bdc2a59a6e",
                                        "subnet-0200203875f2aac93"
                                      ]

existing_public_subnet_ids            = [
                                        "subnet-00a33dd05e8ee1d48"
                                      ]

ecs_existing_private_subnet_ids       = ["subnet-01b9f04bdc2a59a6e"]

image_url                             = "342946498337.dkr.ecr.us-east-1.amazonaws.com/selfheal:latest"


db_username                           = "admin"
db_password                           = "Admin-123"


server_cert_path                      = "./certs/server.crt"
server_key_path                       = "./certs/server.key"
ca_cert_path                          = "./certs/ca.crt"
ca_key_path                           = "./certs/ca.key"

bucket_name                           = "self-healing-system-dgs"
