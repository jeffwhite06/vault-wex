variable "environment" {
  type = string
}

variable "team_path" {
  type = string
}

variable "iam" {
  type = list(map(string))
}

variable "kv_mount" {
  type = string
}

variable "policies" {
  type = list(string)
}