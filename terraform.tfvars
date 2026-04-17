region          = "ap-south-1"
vpc_id = "vpc-035f6f9ebe230c983"

create_subnets = true


availability_zones = ["ap-south-1a", "ap-south-1b"]


public_subnet_cidrs  = ["172.31.48.0/24"]
private_subnet_cidrs = ["172.31.49.0/24", "172.31.50.0/24"]


# create_subnets = false

# existing_private_subnet_ids = [
#   "subnet-aaa",
#   "subnet-bbb"
# ]

image_url = "960451805606.dkr.ecr.ap-south-1.amazonaws.com/selfheal:latest"