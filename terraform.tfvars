region          = "ap-south-1"
vpc_id = "vpc-035f6f9ebe230c983"

create_subnets = false

availability_zones = ["ap-south-1a", "ap-south-1b"]




# public_subnet_cidrs  = ["172.31.48.0/24", "172.31.49.0/24"]
# private_subnet_cidrs = ["172.31.50.0/24", "172.31.51.0/24"]


# create_subnets = false

existing_private_subnet_ids = [
  "subnet-05f0906a24418b482",
  "subnet-0e85d89a34f5b3c1d"
]

existing_public_subnet_ids = [
  "subnet-0eb650ce0586492a6",
  "subnet-0319c9cdb98c09a59"
]

image_url = "960451805606.dkr.ecr.ap-south-1.amazonaws.com/selfheal:latest"


db_username = "admin"
db_password = "Admin-123"
