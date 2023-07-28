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

resource "aws_instance" "example" {
  count = length(var.iam)

  ami                         = "ami-022e1a32d3f742bd8"
  instance_type               = "t2.micro"
  iam_instance_profile        = aws_iam_instance_profile.vault[count.index].name
  key_name                    = "Dev-Bastion"
  associate_public_ip_address = true
  subnet_id                   = "subnet-1441f34d"
  vpc_security_group_ids      = ["sg-09d16d6d"]

  tags = {
    Name = "jeff-${var.iam[count.index].name}"
  }
}