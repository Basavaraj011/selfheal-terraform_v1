region          = "ap-south-1"
vpc_id = "vpc-035f6f9ebe230c983"

create_subnets = true

az                  = "ap-south-1a"
public_subnet_cidr  = "10.0.1.0/24"
private_subnet_cidr = "10.0.2.0/24"

# create_subnets = false

# existing_private_subnet_ids = [
#   "subnet-aaa",
#   "subnet-bbb"
# ]

image_url = "960451805606.dkr.ecr.ap-south-1.amazonaws.com/selfheal:latest"