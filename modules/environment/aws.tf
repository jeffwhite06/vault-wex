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
  count = length(var.iam)

  name = var.iam[count.index].role

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
  count = length(var.iam)

  name = aws_iam_role.vault[count.index].name
  role = aws_iam_role.vault[count.index].name
}

module "instances" {
  source = "../instance"

  names             = var.iam[*].name
  instance_profiles = aws_iam_instance_profile.vault[*].name
}