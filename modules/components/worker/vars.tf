variable "base-name" {
  type = string
}

variable "service-name" {
  type = string
}

variable "deployment-tag" {
  type = string
}

variable "standard-tags" {
  type = map(string)
}

variable "repository-url" {
  type = string
}

variable "cluster-arn" {
  type = string
}

variable "aws-region" {
  type    = string
  default = "us-east-1"
}

variable "vpc-id" {
  type = string
}

variable "subnet-a-id" {
  type = string
}

variable "subnet-b-id" {
  type = string
}

variable "internal-security-group-id" {
  type = string
}

variable "desired-instances" {
  type    = number
  default = 1
}

variable "environment" {
  type = list(object({
    name  = string
    value = string
  }))

  default = []
}

variable "memory" {
  type    = string
  default = "512"
}

variable "healthcheck-grace-seconds" {
  type    = number
  default = 5
}

variable "secrets"{
  type = list(object({
    name  = string
    valueFrom = string
  }))

  default = []
}