data "aws_vpc" "this" {
  tags = {
    Name = "Dev VPC"
  }
}

data "aws_subnets" "this" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }

  filter {
    name   = "map-public-ip-on-launch"
    values = [true] 
  }

}

data "aws_security_group" "this" {
  name   = "Dev-Bastion"
  vpc_id = data.aws_vpc.this.id
}

resource "aws_instance" "example" {
  count = length(var.names)

  ami                         = "ami-03c78641af2c4ba60"
  instance_type               = "t2.micro"
  iam_instance_profile        = var.instance_profiles[count.index]
  key_name                    = "Dev-Bastion"
  associate_public_ip_address = true
  subnet_id                   = data.aws_subnets.this.ids[0]
  vpc_security_group_ids      = [data.aws_security_group.this.id]

  tags = {
    Name = "jeff-${var.names[count.index]}"
  }
}