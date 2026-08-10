module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "selfheal"

  cidr = "10.90.64.128/25"

  azs = ["us-east-1a", "us-east-1b"]

  public_subnets = [
    "10.90.64.128/27"
  ]

  private_subnets = [
    "10.90.64.160/27",
    "10.90.64.192/27"
  ]

  enable_nat_gateway = true
  single_nat_gateway = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = {
    Name = "selfheal-public"
  }


  private_subnet_names = [
    "selfheal-pvt-subnet-1",
    "selfheal-pvt-subnet-2"
  ]


  igw_tags = {
    Name = "selfheal-igw"
  }

  nat_gateway_tags = {
    Name = "selfheal-nat"
  }

  public_route_table_tags = {
    Name = "selfheal-public-rt"
  }

  private_route_table_tags = {
    Name = "selfheal-private-rt"
  }

  tags = {
    Project = "selfheal"
  }
}