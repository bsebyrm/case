terraform {
  required_version = ">=1.4.0"

  required_providers {
    huaweicloud = {
      source  = "huaweicloud/huaweicloud"
      version = ">=1.70.0"
    }
  }
}

provider "huaweicloud" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

############################
# VPC
############################
resource "huaweicloud_vpc" "vpc" {
  name = "${var.cluster_name}-vpc"
  cidr = "10.0.0.0/16"
}

############################
# Subnet
############################
resource "huaweicloud_vpc_subnet" "subnet" {
  name              = "${var.cluster_name}-subnet"
  vpc_id            = huaweicloud_vpc.vpc.id
  cidr              = "10.0.1.0/24"
  gateway_ip        = "10.0.1.1"
  availability_zone = var.availability_zone
}

############################
# Security Group
############################
resource "huaweicloud_networking_secgroup" "sg" {
  name                 = "${var.cluster_name}-sg"
  delete_default_rules = true
}

# SSH
resource "huaweicloud_networking_secgroup_rule" "ssh" {
  security_group_id = huaweicloud_networking_secgroup.sg.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
}

# HTTP
resource "huaweicloud_networking_secgroup_rule" "http" {
  security_group_id = huaweicloud_networking_secgroup.sg.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
}

# All egress
resource "huaweicloud_networking_secgroup_rule" "all_out" {
  security_group_id = huaweicloud_networking_secgroup.sg.id
  direction         = "egress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 1
  port_range_max    = 65535
  remote_ip_prefix  = "0.0.0.0/0"
}

############################
# CCE Cluster
############################
resource "huaweicloud_cce_cluster" "cluster" {
  name                   = var.cluster_name
  cluster_version        = "v1.27"
  flavor_id              = "cce.s1.small"
  vpc_id                 = huaweicloud_vpc.vpc.id
  subnet_id              = huaweicloud_vpc_subnet.subnet.id
  container_network_type = "overlay_l2"
}

############################
# Node
############################
resource "huaweicloud_cce_node" "nodes" {
  count        = var.node_count
  cluster_id   = huaweicloud_cce_cluster.cluster.id
  name         = "${var.cluster_name}-node-${count.index}"
  flavor_id    = var.node_flavor
  key_pair     = var.key_pair
  os           = "EulerOS 2.9"
  availability_zone = var.availability_zone

  root_volume {
    size       = 40
    volumetype = "SSD"
  }

  data_volumes {
    size       = 100
    volumetype = "SSD"
  }
}

############################
# kubeconfig almak için
############################

