locals {
  user = "aws-vault-user-${var.layer}"
}

resource "aws_iam_user" "vault" {
  name = local.user
  path = "/"
}

resource "aws_iam_user_policy" "vault" {
  name = "${local.user}-policy"
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
  count = length(var.names)

  name = "${var.layer}-${var.names[count.index]}-vault-role"

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
  count = length(var.names)

  name = aws_iam_role.vault[count.index].name
  role = aws_iam_role.vault[count.index].name
}