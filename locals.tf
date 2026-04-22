locals {
  resource_suffix = "selfheal"

  public_subnet_ids  = var.existing_public_subnet_ids
  private_subnet_ids = var.existing_private_subnet_ids

  image_url = "${module.ecr.repository_url}:latest"

  private_route_table_ids = var.existing_private_route_table_ids
}