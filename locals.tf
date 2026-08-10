locals {
  resource_suffix = "selfheal"
  image_url = "${module.ecr.repository_url}:latest"
}