#provider
variable "my_region" {
  type        = string
  default   = "eu-central-1"
  description = "instance region"
}
#networks
variable "vpc_cidr_block" {
  type        = string
  default     = "10.0.0.0/16"
  description = "the cidr block of vpc, usually class B."
}

variable "is_enable_dns_hostname" {
  type        = bool
  default     = true
  description = "define if dns hostname is enable."
}

variable "vpc_name" {
  type        = string
  default     = "my_default_vcp"
  description = "vpc name."
}

variable "igw_name" {
  type        = string
  default     = "my_default_vpc"
  description = "igw name."
}

variable "rt_igw_cidr_block" {
  type        = string
  default     = "0.0.0.0/0"
  description = "the route table igw cidr"
}

variable "raute_table_name" {
  type        = string
  default     = "default_route_table"
  description = "the raute table name."
}

variable "subnet_1_cidr_block" {
  type        = string
  default     = "10.0.1.0/24"
  description = "cider block of subnet 1"
}

variable "az_subnet_1" {
  type        = string
  default     = "eu-central-1a"
  description = "The az of subnet 1."
}

variable "subnet_1_name" {
  type        = string
  default     = "default_subnet_1_name"
  description = "the subnet 1 name."
}

#instances
variable "image_aws" {
  type        = string
  default     = "ami-00f22f6155d6d92c5"
  description = "the image of aws."
}

variable "my_instance_type" {
  type        = string
  default     = "t2.micro"
  description = "my instance type."
}

variable "my_key_name" {
  type        = string
  default     = "260621"
  description = "the name of my key value."
}

variable "first_instance_name" {
  type        = string
  default     = "defualt_srv_instance_1"
  description = "my 1 instance name."
}

variable "security_group_name" {
  type = string
  default = "default_sg"
}

variable "iam_instance_profile" {
  type = string
  default = "iam-ted-search"
}

