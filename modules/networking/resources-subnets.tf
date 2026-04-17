resource "aws_subnet" "public" {
  count = var.create_subnets ? 1 : 0

  vpc_id                  = var.vpc_id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.az
  map_public_ip_on_launch = true

  tags = {
    Name = "public-${var.resource_suffix}"
    Tier = "public"
  }
}

resource "aws_subnet" "private" {
  count = var.create_subnets ? 1 : 0

  vpc_id            = var.vpc_id
  cidr_block        = var.private_subnet_cidr
  availability_zone = var.az

  map_public_ip_on_launch = false

  tags = {
    Name = "private-${var.resource_suffix}"
    Tier = "private"
  }
}