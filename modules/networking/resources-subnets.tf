resource "aws_subnet" "public" {
  count = var.create_subnets ? length(var.public_subnet_cidrs) : 0

  vpc_id                  = var.vpc_id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "public-${count.index}-${var.resource_suffix}"
    Tier = "public"
  }
}

resource "aws_subnet" "private" {
  count = var.create_subnets ? length(var.private_subnet_cidrs) : 0

  vpc_id            = var.vpc_id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  map_public_ip_on_launch = false

  tags = {
    Name = "private-${count.index}-${var.resource_suffix}"
    Tier = "private"
  }
}
