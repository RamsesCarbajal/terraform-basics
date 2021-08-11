variable "enabled" { type = bool }
variable "base-name" { type = string }
variable "standard-tags" { type = map(string) }
variable "public-http-security-group-id" { type = string }
variable "subnet-a-id" { type = string }
variable "subnet-b-id" { type = string }
variable "vpc-id" { type = string }
variable "certificate-arn" { type = string }

variable "service-name" { type = string }
variable "internal-security-group" { type = string }

variable "health-path" {
  type    = string
  default = "/ping"
}

variable "environment" {
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "repository-url" { type = string }
variable "deployment-tag" { type = string }
variable "aws-region" { type = string }
variable "app-port" { type = number }
variable "memory" {
  type    = string
  default = "512"
}
variable "cluster-arn" {}
variable "desired-instances" {
  type    = number
  default = 1
}
variable "healthcheck-grace-seconds" {
  type    = number
  default = 15
}

variable "internal-health-command-enabled" {
  type    = bool
  default = true
}

variable "internal-health-command" {
  type    = string
  default = null
}

variable "command" {
  type    = list(string)
  default = null
}

variable "entrypoint" {
  type    = list(string)
  default = null
}

variable "bind-volumes" {
  type = map(object({
    sourcePath    = string
    containerPath = string
    readonly      = bool
  }))

  default = {}
}

variable "launch-type" {
  type    = string
  default = "FARGATE"
}

variable "healthcheck-matcher" {
  type    = string
  default = "200"
}

variable "secrets_environment"{
  type = list(object({
    name  = string
    valueFrom = string
  }))

  default = []
}