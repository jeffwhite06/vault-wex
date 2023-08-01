variable "environment" {
  type = string
}

variable "team_path" {
  type = string
}

variable "iam" {
  type = list(map(string))
}

variable "policies" {
  type = list(string)
}

variable "kv_store" {
  type = string
}