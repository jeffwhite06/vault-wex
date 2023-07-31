locals {
  admin_namespace = "admin"
}

resource "vault_github_auth_backend" "github" {
  organization = var.github_org
}

resource "aws_iam_user" "vault" {
  name = "aws-vault-user-admin"
  path = "/"
}

resource "aws_iam_user_policy" "vault" {
  name = "aws-vault-user-admin-policy"
  user = aws_iam_user.vault.name

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "VisualEditor0",
        "Effect" : "Allow",
        "Action" : [
          "iam:GetRole",
          "ec2:DescribeInstances",
          "iam:GetInstanceProfile",
          "iam:ListRoles",
          "iam:GetUser"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_access_key" "vault" {
  user = aws_iam_user.vault.name
}

resource "aws_iam_role" "vault" {
  name = "aws-vault-role-admin"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_instance_profile" "vault" {
  name = aws_iam_role.vault.name
  role = aws_iam_role.vault.name
}

resource "vault_auth_backend" "iam" {
  type = "aws"
}

resource "vault_aws_auth_backend_client" "iam" {
  backend    = vault_auth_backend.iam.path
  access_key = aws_iam_access_key.vault.id
  secret_key = aws_iam_access_key.vault.secret
}

resource "vault_mount" "admin_kv" {
  path = "secret"
  type = "kv"
  options = {
    version = "2"
  }
}

resource "vault_kv_secret_backend_v2" "admin_kv" {
  mount = vault_mount.admin_kv.path
}

resource "vault_kv_secret_v2" "admin" {
  mount = vault_mount.admin_kv.path
  name  = "example"

  data_json = jsonencode({
    username = "username",
    password = "password"
  })
}

module "admin_admins" {
  source = "./modules/admin"

  team                 = var.admin_team
  github_auth_id       = vault_github_auth_backend.github.id
  github_auth_accessor = vault_github_auth_backend.github.accessor
  policy               = file("./vault-policies/admin/admin.hcl")
}

module "admin_engineering" {
  source = "./modules/admin"

  team                 = var.team
  github_auth_id       = vault_github_auth_backend.github.id
  github_auth_accessor = vault_github_auth_backend.github.accessor
}

module "admin_security" {
  source = "./modules/admin"

  team                 = var.security_team
  github_auth_id       = vault_github_auth_backend.github.id
  github_auth_accessor = vault_github_auth_backend.github.accessor
  policy               = file("./vault-policies/admin/security.hcl")
}

resource "vault_aws_auth_backend_role" "app" {
  backend                  = vault_auth_backend.iam.path
  role                     = "admin"
  auth_type                = "iam"
  bound_iam_principal_arns = [aws_iam_role.vault.arn]
  resolve_aws_unique_ids   = true
  token_policies           = ["default", module.admin_admins.policy]

  depends_on = [vault_aws_auth_backend_client.iam]
}

module "instance" {
  source = "./modules/instance"
  
  names             = ["admin"]
  instance_profiles = [aws_iam_instance_profile.vault.name]
}