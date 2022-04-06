
/* 

Remark: This Terraform scripts are just examples how to provision Resource on Huawei Cloud. 
(Not recommended to use this for production system!!)

For more information, You can visit this following URL https://registry.terraform.io/providers/huaweicloud/huaweicloud

*/



#Provide Cloud provider information (Cloud vendor, Region, AK/SK)
provider "huaweicloud" {
  region     = var.my-credential.region
  access_key = var.my-credential.ak
  secret_key = var.my-credential.sk
}

terraform {
  required_providers {
    huaweicloud = {
      source  = "huaweicloud/huaweicloud"
      version = "~> 1.33.0"
    }
  }
}

#Create VPC with 3 subnet

resource "huaweicloud_vpc" "vpc" {
  name = var.vpc-info.name
  cidr = var.vpc-info.cidr
  enterprise_project_id = data.huaweicloud_enterprise_project.eps.id
}
resource "huaweicloud_vpc_subnet" "subnet1" {
  name       = var.subnet1.name
  cidr       = var.subnet1.cidr
  gateway_ip = var.subnet1.gw
  vpc_id     = huaweicloud_vpc.vpc.id
}
resource "huaweicloud_vpc_subnet" "subnet2" {
  name       = var.subnet2.name
  cidr       = var.subnet2.cidr
  gateway_ip = var.subnet2.gw
  vpc_id     = huaweicloud_vpc.vpc.id
}
resource "huaweicloud_vpc_subnet" "subnet3" {
  name       = var.subnet3.name
  cidr       = var.subnet3.cidr
  gateway_ip = var.subnet3.gw
  vpc_id     = huaweicloud_vpc.vpc.id
}

#Create Security Group for ECS, MySQL DB, RabbitMQ, Mongo DB, Elastic search

resource "huaweicloud_networking_secgroup" "secgroup_ecs" {
  name        = "secgroup_ecs"
  enterprise_project_id = data.huaweicloud_enterprise_project.eps.id
  description = "security group for ECS"
}

resource "huaweicloud_networking_secgroup" "secgroup_db" {
  name        = "secgroup_db"
  enterprise_project_id = data.huaweicloud_enterprise_project.eps.id
  description = "security group for MySQL DB"
}

resource "huaweicloud_networking_secgroup" "secgroup_mq" {
  name        = "secgroup_mq"
  enterprise_project_id = data.huaweicloud_enterprise_project.eps.id
  description = "security group for Rabbit MQ"
}

resource "huaweicloud_networking_secgroup" "secgroup_mongo" {
  name        = "secgroup_mongo"
  enterprise_project_id = data.huaweicloud_enterprise_project.eps.id
  description = "security group for Mongo DB"
}

resource "huaweicloud_networking_secgroup" "secgroup_css" {
  name        = "secgroup_css"
  enterprise_project_id = data.huaweicloud_enterprise_project.eps.id
  description = "security group for Elastic Search"
}

# Create ECS on public subnet

resource "huaweicloud_compute_instance" "ecs1" {
  name               = var.ecs1.name
  image_name           = var.ecs1.image
  flavor_name          = var.ecs1.flavor
  security_group_ids = [huaweicloud_networking_secgroup.secgroup_ecs.id]
  availability_zone  = var.ecs1.az
  enterprise_project_id = data.huaweicloud_enterprise_project.eps.id
  network {
    uuid = huaweicloud_vpc_subnet.subnet1.id
  }
}


# create CCE K8S cluster (HA Cluster) with 3 Worker Nodes
resource "huaweicloud_cce_cluster" "cluster" {
  name                   = var.cce-info.name
  cluster_type           = "VirtualMachine"
  flavor_id              = "cce.s2.small"
  multi_az               = true
  vpc_id                 = huaweicloud_vpc.vpc.id
  subnet_id              = huaweicloud_vpc_subnet.subnet1.id
  container_network_type = "vpc-router"
  authentication_mode    = "rbac"
  enterprise_project_id = data.huaweicloud_enterprise_project.eps.id
}

resource "huaweicloud_cce_node" "node1" {
  cluster_id        = huaweicloud_cce_cluster.cluster.id
  name              = "node1"
  flavor_id         = var.cce-info.vm_node_flavor
  availability_zone = "ap-southeast-2a"
  password = var.cce-info.vm_node_pass
  os = var.cce-info.vm_node_os

  root_volume {
    size       = 40
    volumetype = "SSD"
  }
  data_volumes {
    size       = 100
    volumetype = "SSD"
  }
}

resource "huaweicloud_cce_node" "node2" {
  cluster_id        = huaweicloud_cce_cluster.cluster.id
  name              = "node2"
  flavor_id         = var.cce-info.vm_node_flavor
  availability_zone = "ap-southeast-2b"
  password = var.cce-info.vm_node_pass
  os = var.cce-info.vm_node_os

  root_volume {
    size       = 40
    volumetype = "SSD"
  }
  data_volumes {
    size       = 100
    volumetype = "SSD"
  }
}

resource "huaweicloud_cce_node" "node3" {
  cluster_id        = huaweicloud_cce_cluster.cluster.id
  name              = "node3"
  flavor_id         = var.cce-info.vm_node_flavor
  availability_zone = "ap-southeast-2c"
  password = var.cce-info.vm_node_pass
  os = var.cce-info.vm_node_os

  root_volume {
    size       = 40
    volumetype = "SSD"
  }
  data_volumes {
    size       = 100
    volumetype = "SSD"
  }
}

# Create RDS for MySQL HA Mode (AZ1, AZ2) 

resource "huaweicloud_rds_instance" "mysql_db" {
  name                = var.rds-info.name
  flavor              = var.rds-info.rds_flavor
  ha_replication_mode = var.rds-info.ha_mode
  vpc_id              = huaweicloud_vpc.vpc.id
  subnet_id           = huaweicloud_vpc_subnet.subnet3.id
  security_group_id   = huaweicloud_networking_secgroup.secgroup_db.id
  enterprise_project_id = data.huaweicloud_enterprise_project.eps.id
  availability_zone   = [
    "ap-southeast-2a",
    "ap-southeast-2b"]

  db {
    type     = var.rds-info.rds_engine
    version  = var.rds-info.rds_engine_version
    password = var.rds-info.rds_pass
  }
  volume {
    type = var.rds-info.rds_disk_type
    size = var.rds-info.rds_disk
  }
  backup_strategy {
    start_time = "23:00-00:00"
    keep_days  = var.rds-info.rds_backup_retention
  }
}

# Create DCS for Redis ver.5.0 as Single-Node mode on Private Subnet 

resource "huaweicloud_dcs_instance" "dcs_redis" {
  name               = var.dcs-info.name
  engine             = var.dcs-info.dcs_engine
  engine_version     = var.dcs-info.dcs_engine_version
  capacity           = var.dcs-info.dcs_capacity
  flavor             = var.dcs-info.dcs_flavor
  availability_zones = [var.dcs-info.dcs_az]
  password           = var.dcs-info.dcs_auth
  vpc_id             = huaweicloud_vpc.vpc.id
  subnet_id          = huaweicloud_vpc_subnet.subnet2.id
  enterprise_project_id = data.huaweicloud_enterprise_project.eps.id
}

# Create DMS for RabbitMQ as Single-Node mode on Private Subnet
data "huaweicloud_dms_az_v1" "Query_mq_az" {
  code = var.dms-info.dms_az
}

data "huaweicloud_dms_product" "Query_mq" {
  engine        = "rabbitmq"
  instance_type = var.dms-info.dms_mode
  version       = var.dms-info.dms_engine_version
  node_num      = 1
}
resource "huaweicloud_dms_rabbitmq_instance" "dms_rabbitmq" {
  name              = var.dms-info.name
  product_id        = data.huaweicloud_dms_product.Query_mq.id
  engine_version    = var.dms-info.dms_engine_version
  storage_spec_code = var.dms-info.dms_disk_type
  storage_space     = var.dms-info.dms_disk_size
  vpc_id             = huaweicloud_vpc.vpc.id
  network_id         = huaweicloud_vpc_subnet.subnet2.id
  security_group_id  = huaweicloud_networking_secgroup.secgroup_mq.id
  enterprise_project_id = data.huaweicloud_enterprise_project.eps.id
  available_zones = [data.huaweicloud_dms_az_v1.Query_mq_az.id]

  access_user = var.dms-info.dms_user
  password    = var.dms-info.dms_pass
}

# Create DDS for Mongo as Shard Cluster on DB subnet
resource "huaweicloud_dds_instance" "mongo_shard" {
  name = var.dds-shard-info.name
  datastore {
    type           = var.dds-shard-info.dds_engine
    version        = var.dds-shard-info.dds_engine_version
    storage_engine = "wiredTiger"
  }

  availability_zone = var.dds-shard-info.dds_az
  vpc_id            = huaweicloud_vpc.vpc.id
  subnet_id         = huaweicloud_vpc_subnet.subnet3.id
  security_group_id = huaweicloud_networking_secgroup.secgroup_mongo.id
  password          = var.dds-shard-info.dds_pass
  mode              = var.dds-shard-info.dds_mode
  enterprise_project_id = data.huaweicloud_enterprise_project.eps.id
  flavor {
    type      = "mongos"
    num       = var.dds-shard-info.dds_mongos_num
    spec_code = var.dds-shard-info.dds_mongos_spec
  }
  flavor {
    type      = "shard"
    num       = var.dds-shard-info.dds_shard_num
    storage   = "ULTRAHIGH"
    size      = var.dds-shard-info.dds_shard_size
    spec_code = var.dds-shard-info.dds_shard_spec
  }
  flavor {
    type      = "config"
    num       = 1
    storage   = "ULTRAHIGH"
    size      = 20
    spec_code = "dds.mongodb.s6.large.2.config"
  }
  backup_strategy {
    start_time = "23:00-00:00"
    keep_days  = "1"
  }
}


# Create CSS for Elastic Search Cluster + Kibana on Private subnet
resource "huaweicloud_css_cluster" "css_cluster" {
  expect_node_num = var.css-info.css_node_num
  name            = var.css-info.name
  engine_version  = var.css-info.css_engine_version
  enterprise_project_id = data.huaweicloud_enterprise_project.eps.id
  node_config {
    flavor = var.css-info.css_spec
    availability_zone = var.css-info.css_az

    network_info {
      security_group_id = huaweicloud_networking_secgroup.secgroup_css.id
      subnet_id         =  huaweicloud_vpc_subnet.subnet2.id
      vpc_id            =  huaweicloud_vpc.vpc.id
    }

    volume {
      volume_type = var.css-info.css_disk_type
      size        = var.css-info.css_disk_size
    }
  }
   lifecycle {
    ignore_changes = [
      enterprise_project_id
    ]
  }
}

# Create OBS bucket
resource "huaweicloud_obs_bucket" "obs" {
  bucket = "terraform-test-bucket"
  acl    = "private"
  versioning = true
  multi_az = true
  enterprise_project_id = data.huaweicloud_enterprise_project.eps.id
}
