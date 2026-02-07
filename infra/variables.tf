variable "region" {
  default = "ap-southeast-2"
}

variable "access_key" {}
variable "secret_key" {}

variable "cluster_name" {
  default = "buse-cce"
}

variable "node_count" {
  default = 2
}

variable "availability_zone" {
  description = "örn: ap-southeast-2a"
}

variable "node_flavor" {
  default = "s6.large.2"
}

variable "key_pair" {
  description = "Huawei cloud keypair name"
}
