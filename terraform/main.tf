terraform {
  required_providers {
    huaweicloud = {
      source  = "huaweicloud/huaweicloud"
      version = ">= 1.50.0"
    }
  }
}

provider "huaweicloud" {
  region     = "ap-southeast-3"
  access_key = var.access_key
  secret_key = var.secret_key
}

########################
# VPC
########################

resource "huaweicloud_vpc" "vpc" {
  name = "devops-vpc"
  cidr = "192.168.0.0/16"
}

resource "huaweicloud_vpc_subnet" "subnet" {
  name       = "devops-subnet"
  cidr       = "192.168.1.0/24"
  gateway_ip = "192.168.1.1"
  vpc_id     = huaweicloud_vpc.vpc.id
}

########################
# SECURITY GROUP
########################

resource "huaweicloud_networking_secgroup" "secgroup" {
  name = "devops-secgroup"
}

resource "huaweicloud_networking_secgroup_rule" "allow_all" {
  direction         = "ingress"
  ethertype         = "IPv4"
  security_group_id = huaweicloud_networking_secgroup.secgroup.id
  remote_ip_prefix  = "0.0.0.0/0"
}


########################
# CCE CLUSTER
########################

resource "huaweicloud_cce_cluster" "cluster" {
  name            = "cce-demo"
  cluster_version = "v1.25"
  flavor_id       = "cce.s1.small"

  vpc_id    = huaweicloud_vpc.vpc.id
  subnet_id = huaweicloud_vpc_subnet.subnet.id

  container_network_type = "overlay_l2"
}


########################
# NODE POOL
########################

resource "huaweicloud_cce_node_pool" "nodepool" {
  cluster_id               = huaweicloud_cce_cluster.cluster.id
  name                     = "nodepool1"
  os                       = "EulerOS 2.9"
  flavor_id                = "s6.large.2"
  initial_node_count       = 1
  availability_zone        = var.a_zone

  password = "Devops123!"


  root_volume {
    size       = 40
    volumetype = "SSD"
  }

  data_volumes {
    size       = 100
    volumetype = "SSD"
  }
}



