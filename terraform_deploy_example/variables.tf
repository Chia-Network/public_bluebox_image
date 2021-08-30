//This is a list of the default that will apply to all instances. If a particular variable need to have a specific or unique value,
//it shall be added to the vars directory, as a xxx.tfvars.file
variable "region" {
  description = "AWS Region"
  type = string
  default = ""
}

variable "desired_capacity" {
  default = "2"
}
variable "max_size" {
  default = "2"
}
variable "min_size" {
  default = "1"
}
variable "security_group_pattern" {
  description = "SG patterns to add to the instance"
  type = string
  default = ""
}
variable "key_name" {
  description = "instance private key file aws name"
  type = string
  default = ""
}

variable "iam_instance_profile" {
  description = "Name of iam_instance_profile"
  type = string
  default = ""
}

variable "vpc_name_filter" {
  description = "Find VPC"
  type = string
  default = ""
}

variable "instance_name" {
  description = "Name of the instances"
  type = string
  default = "Bluebox_Timelord"
}

variable "instance_type_1" {
  description = "The preferred choice of instance type"
  type = string
  default = ""
}

variable "instance_type_2" {
  description = "The preferred choice of instance type"
  type = string
  default = ""
}

//variable "instance_type_3" {
//  description = "The preferred choice of instance type"
//  type = string
//  default = ""
//}
