provider "vault" {
  address   = "https://vault-cluster-public-vault-7e14cb83.b404f542.z1.hashicorp.cloud:8200"
  namespace = local.admin_namespace
}

provider "aws" {
  region = "us-east-1"

  assume_role {
    role_arn = "arn:aws:iam::${var.environments[0].aws_account}:role/UCFIT_Automation_Admin"
  }
}

provider "aws" {
  alias  = "dev"
  region = "us-east-1"

  assume_role {
    role_arn = "arn:aws:iam::${var.environments[1].aws_account}:role/UCFIT_Automation_Admin"
  }
}