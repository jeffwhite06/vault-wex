provider "vault" {
  address   = "https://vault-cluster-public-vault-37f8ddfa.d004b5ab.z1.hashicorp.cloud:8200"
  namespace = local.admin_namespace
}

provider "aws" {
  region = "us-east-1"
}