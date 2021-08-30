// Create this for every tf project (repository)
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
  backend "s3" {  // Where the state file will live in for terraform
    bucket = ""
    key = "terraform.tfstate"
    region = "us-west-2"
    workspace_key_prefix = ""
  }
}
provider "aws" {
  region = var.region
}
terraform {
  required_version = ">= 0.12"
}

data "aws_vpc" "vpc" {
  filter {
    name = "tag:Name"
    values = [
      var.vpc_name_filter]
  }
}

data "aws_security_groups" "sgs" {
  filter {
    name = "tag:Name"
    values = [
      "private-ssh",
      var.security_group_pattern]
  }

  filter {
    name = "vpc-id"
    values = [
      data.aws_vpc.vpc.id]
  }
}

data "aws_security_groups" "sgs" {
  filter {
    name = "tag:Name"
    values = [
      "private-ssh",
      var.security_group_pattern]
  }

  filter {
    name = "vpc-id"
    values = [
      data.aws_vpc.vpc.id]
  }
}
// This data source is searching for an AMI named "Chia_Bluebox_Base" that is the most recent. This when then be used to get the image_id in the aws_launch_template
data "aws_ami" "Bluebox" {
  most_recent = true
  owners = [
    "self"]

  filter {
    name = "name"
    values = [
      "Chia_Bluebox_Base*"]
  }
}

resource "aws_autoscaling_group" "bluebox" {
  desired_capacity = var.desired_capacity
  max_size = var.max_size
  min_size = var.min_size
  capacity_rebalance = true
  health_check_type = "ELB"
  health_check_grace_period = 300

  mixed_instances_policy {
    instances_distribution {
      on_demand_base_capacity = 0 // Change this value if spot-instances are desired. This is not recommended for Bluebox Timelords
      on_demand_percentage_above_base_capacity = 0
      spot_allocation_strategy = "lowest-price" // The other option for spot_allocation_strategy is capacity-optimized. However, we are more concerned with the price over availability.
      //The Spot Instances come from the pools with optimal capacity for the number of instances that are launching. You can optionally set a priority for each instance type.
      spot_instance_pools = 4
      spot_max_price = "0.035" // If the spot instances exceed the maximum, they will automatically be scaled down to "0".
    }

    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.bluebox.id
        version = "$Latest"
      }

      override {   // This is the preferential instance type that will be launched instead of the specified type in the aws_launch_template
        instance_type = var.instance_type_2
      }
    }
  }
}
resource "aws_launch_template" "bluebox" {
  name = "bluebox"
  image_id = data.aws_ami.Bluebox.id
  instance_type = var.instance_type_1
  key_name = var.key_name

  block_device_mappings {   // This will mount an EBS volume of 50GB. Some instance-types have specific capacities associated with them.
    device_name = "/dev/sda1"

    ebs {
      volume_size = 50
      volume_type = "gp2"
      delete_on_termination = "true"
      encrypted = "false"
    }
  }

  iam_instance_profile {
    name = var.iam_instance_profile
  }

  lifecycle {
    create_before_destroy = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = var.instance_name
      Value = true
    }
  }
}
