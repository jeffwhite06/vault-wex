locals {
  environment = "prod"
}

resource "vault_namespace" "team" {
  namespace = vault_namespace.fabric.path
  path      = var.team
}

resource "vault_mount" "kv" {
  namespace = vault_namespace.team.path_fq
  path      = local.environment
  type      = "kv"
  options = {
    version = "2"
  }
}

resource "vault_kv_secret_backend_v2" "kv" {
  namespace = vault_namespace.team.path_fq
  mount     = vault_mount.kv.path
}

resource "vault_kv_secret_v2" "example" {
  mount     = vault_mount.kv.path
  namespace = vault_namespace.team.path_fq
  name      = "example"

  data_json = jsonencode({
    username = "username",
    password = "password"
  })
}

resource "vault_mount" "ssh" {
  namespace = vault_namespace.team.path_fq
  type      = "ssh"
  path      = "ssh"
}

resource "vault_policy" "iam" {
  name      = "iam"
  namespace = vault_namespace.team.path_fq

  policy = <<EOT
path "{{identity.entity.metadata.environment}}/*" {
  capabilities = ["read","list"]
}
EOT
}

resource "aws_iam_user_policy" "vault" {
  name = "aws-iampolicy-for-vault-authmethod"
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

resource "aws_iam_user" "vault" {
  name = "aws-iamuser-for-vault-authmethod"
  path = "/"
}

resource "aws_iam_access_key" "vault" {
  user = aws_iam_user.vault.name
}

resource "aws_iam_role" "vault" {
  name = "aws-ec2role-for-vault-authmethod"

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
  type      = "aws"
  namespace = vault_namespace.team.path_fq
}

resource "vault_aws_auth_backend_client" "iam" {
  backend    = vault_auth_backend.iam.path
  namespace  = vault_namespace.team.path_fq
  access_key = aws_iam_access_key.vault.id
  secret_key = aws_iam_access_key.vault.secret
}

resource "vault_aws_auth_backend_role" "iam" {
  backend                  = vault_auth_backend.iam.path
  namespace                = vault_namespace.team.path_fq
  role                     = "iam-role"
  auth_type                = "iam"
  bound_iam_principal_arns = [aws_iam_role.vault.arn]
  resolve_aws_unique_ids   = true
  token_policies           = [vault_policy.iam.name]

  depends_on = [vault_aws_auth_backend_client.iam]
}

# namespace is broken on this resource - need to provision manually
# resource "vault_aws_auth_backend_config_identity" "iam" {
#   backend      = vault_auth_backend.iam.path
#   namespace    = vault_namespace.team.path_fq
#   iam_alias    = "unique_id"
#   iam_metadata = ["account_id","auth_type","canonical_arn","client_arn","client_user_id","inferred_aws_region","inferred_entity_id","inferred_entity_type"]
# }

resource "aws_instance" "example" {
  count = 2

  ami                         = "ami-022e1a32d3f742bd8"
  instance_type               = "t2.micro"
  iam_instance_profile        = aws_iam_instance_profile.vault.name
  key_name                    = "Dev-Bastion"
  associate_public_ip_address = true
  subnet_id                   = "subnet-1441f34d"
  vpc_security_group_ids      = ["sg-09d16d6d"]

  tags = {
    Name = "jeff-test"
  }
}

resource "vault_identity_entity" "iam" {
  name      = "iam-role"
  namespace = vault_namespace.team.path_fq

  metadata = {
    environment = "prod"
  }
}

resource "vault_identity_entity_alias" "iam" {
  name           = aws_iam_role.vault.unique_id
  namespace      = vault_namespace.team.path_fq
  mount_accessor = vault_auth_backend.iam.accessor
  canonical_id   = vault_identity_entity.iam.id
}
