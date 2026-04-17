locals {
  resource_suffix = "selfheal"

  private_subnet_ids = var.create_subnets ? module.networking.private_subnet_ids : var.existing_private_subnet_ids

  image_url = "${module.ecr.repository_url}:latest"
}