variable "fabric" {
  type    = string
  default = "fabric"
}

variable "team" {
  type    = string
  default = "engineering"
}

variable "github_org" {
  type    = string
  default = "JeffPWhite"
}

variable "environments" {
  type = list(object({
    name        = string
    env_role    = string
    aws_account = number
  }))
  default = [{
    name        = "prod"
    env_role    = "prod"
    aws_account = 338042618416
    }, {
    name        = "dev"
    env_role    = "dev"
    aws_account = 805978250098
  }]
}

variable "admin_team" {
  type    = string
  default = "vault-admins"
}

variable "security_team" {
  type    = string
  default = "security"
}