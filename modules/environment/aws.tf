module "environment_iam" {
  source = "../iam"

  names = var.iam[*].name
  layer = var.environment
}

module "instances" {
  source = "../instance"

  names             = var.iam[*].name
  instance_profiles = module.environment_iam.instance_profiles[*]
}