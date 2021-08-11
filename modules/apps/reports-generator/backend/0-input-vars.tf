variable "environment" {
  type = string
}

variable "app-port" {
  type = string
}

variable "aws-region"{
  type = string
}
variable "base-name" {
  type = string
}

variable "certificate-arn" {
  type = string
}

variable "deployment-tag" {
  type = string
}

variable "subnet-a-id" {
  type = string
}

variable "subnet-b-id" {
  type = string
}

variable "public-http-security-group-id" {
  type = string
}

variable "kafka_client_subnets" {
  type = list(string)
}

variable "kafka_security_groups" {
  type = list(string)
}

variable "app_name" {
  type = string
}

variable "cluster_arn" {
  type = string
}


variable "execution_role_arn" {
  type = string
}

variable "internal_security_group" {
  type = string
}

variable "ecr_url" {
  type = string
}

variable "security_groups" {
  type = list(string)
}

variable "task_role_arn" {
  type = string
}
variable "vpc_id"{
  type = string
}

variable "brokers"{
  type = number
}

variable "kafka_version" {
  type = string
}

variable "kafka_instance_size"{
  type = string
}

variable "standard-tags"{
  type = map(string)
}

variable "domain"{
  type = string
}
variable "enabled" {
  type = bool
}