# AK/SK credential input

variable "my-credential" {
  type = map
  default = {
    "ak" = "xxxxxxxxxxxxxx"     //input AK
    "sk" = "xxxxxxxxxxxxxxxxxxxxxxxxx"  // input SK
    "region" = "ap-southeast-2"  // For Huawei Cloud AP-BKK Region
  } 
}



# Query Enterprise Project 

data "huaweicloud_enterprise_project" "eps" {
  name = "xxxxxxxxxxxx"  // input Enterprise project name, Enterprise Project Management must be enable.
}


# VPC and subnet variable

variable "vpc-info" {
  type = map
  default =  {
    "name" = "terraform-vpc"
    "cidr" = "192.168.0.0/16"
  }
}

variable "subnet1" {
  type = map
  default =  {
    "name" = "public-subnet"
    "cidr" = "192.168.1.0/24"
    "gw" = "192.168.1.1"
  }
}

variable "subnet2" {
  type = map
  default =  {
    "name" = "private-subnet"
    "cidr" = "192.168.2.0/24"
    "gw" = "192.168.2.1"
  }
}

variable "subnet3" {
  type = map
  default =  {
    "name" = "db-subnet"
    "cidr" = "192.168.3.0/24"
    "gw" = "192.168.3.1"
  }
}


# ECS variable
variable "ecs1" {
  type = map
  default =  {
    "name" = "ecs-terraform-1"
    "az" = "ap-southeast-2a" // ap-southeast-2a	AZ1 , ap-southeast-2b	AZ2 , ap-southeast-2c	AZ3
    "flavor" = "c6.large.2"
    "image" = "Ubuntu 18.04 server 64bit"
  }
}
# CCE K8S variable
variable "cce-info" {
  type = map
  default =  {
    "name" = "k8s-terraform"
    "vm_node_flavor" = "c6.large.2"
    "vm_node_pass" = "Thai@ssw0rd"
    "vm_node_os" = "Ubuntu 18.04"
  }
}
# RDS for MySQL variable
variable "rds-info" {
  type = map
  default =  {
    "name" = "mysql-rds-terraform"
    "rds_flavor" = "rds.mysql.n1.xlarge.2.ha"
    "rds_pass" = "Thai@ssw0rd"
    "rds_engine" = "MySQL"
    "rds_engine_version" = "8.0"
    "ha_mode" = "semisync"
    "rds_disk_type" = "CLOUDSSD"
    "rds_disk" = 100  // input Disk size in GB units
    "rds_backup_retention" = 1 // input Retention period in Day units
  }
}
# DCS for Redis variable
variable "dcs-info" {
  type = map
  default =  {
    "name" = "redis-dcs-terraform"
    "dcs_flavor" = "redis.single.xu1.large.4"
    "dcs_capacity" = 4.0 // input Memory cap. in GB units (Float)
    "dcs_auth" = "Huawei@123"
    "dcs_engine" = "Redis"
    "dcs_engine_version" = "5.0"
    "dcs_az" = "ap-southeast-2a"
  }
}
# DMS for RabbitMQ variable
variable "dms-info" {
  type = map
  default =  {
    "name" = "rabbitmq-dms-terraform"
    "dms_id" = ""
    "dms_mode" = "single"
    "dms_disk_type" = "dms.physical.storage.high" // input Disk type Ultra-I/O or High-I/O
    "dms_disk_size" = 100   // input Disk size in GB units
    "dms_engine" = "RabbitMQ"
    "dms_engine_version" = "3.7.17"
    "dms_az" = "ap-southeast-2b"
    "dms_user" = "root"
    "dms_pass" = "Hauwei@123"
  }
}

# DDS for Mongo DB Cluster variable
variable "dds-shard-info" {
  type = map
  default =  {
    "name" = "shard-mongo-terraform"
    "dds_mode" = "Sharding"
    "dds_engine" = "DDS-Community"
    "dds_engine_version" = "4.0"
    "dds_az" = "ap-southeast-2c"
    "dds_pass" = "Hauwei@123"
    "dds_mongos_num" = 2
    "dds_mongos_spec" = "dds.mongodb.s6.large.2.mongos"
    "dds_shard_num" = 2
    "dds_shard_spec" = "dds.mongodb.s6.large.2.shard"
    "dds_shard_size" = 20 // input Shard Storage in GB 
    "dds_backup_retention" = "1" // input Retention period in Day units
  }
}

# CSS for Elastic Search Cluster variable
variable "css-info" {
  type = map
  default =  {
    "name" = "elasticsearch-css-terraform"
    "css_engine_version" = "7.9.3"
    "css_az" = "ap-southeast-2a,ap-southeast-2b,ap-southeast-2c"
    "css_pass" = "Hauwei@123"
    "css_node_num" = 4
    "css_spec" = "ess.spec-4u8g"
    "css_disk_type" = "HIGH" 
    "css_disk_size" = 40 // input disk size in GB 
  }
}
