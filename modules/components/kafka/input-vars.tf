variable "environment"{
  type = string
}
variable "base_name" {
  type = string
}
variable "kafka_client_subnets" {
  type = list(string)
}
variable "kafka_security_groups" {
  type = list(string)
}
variable "brokers" {
  type = number
}
variable "kafka_version" {
  type = string
}
variable "kafka_instance_size" {
  type = string
}