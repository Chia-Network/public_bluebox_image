provider "aws" {
  region = var.region1
}

//provider "aws" {
//  alias  = "region2"
//  region = var.region2
//}
//
//provider "aws" {
//  alias  = "region3"
//  region = var.region3
//}
//
//provider "aws" {
//  alias  = "region4"
//  region = var.region4
//}
//
//provider "aws" {
//  alias  = "region5"
//  region = var.region5
//}
//
//terraform {
//  backend "s3" {
//    bucket = var.s3_bucket_name
//    key    = var.s3_bucket_key
//    region = var.s3_bucket_region
//  }
//}

data "aws_ami" "ami" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = [var.source_ami_pattern]
  }
}

//module "ami_copy_region2" {
//  source            = "git::https://github.com/Chia-Network/terraform-modules.git//ami_copy"
//  source_ami_id     = data.aws_ami.ami.id
//  image_copy_name   = var.image_copy_name
//  source_ami_region = var.region1
//  providers         = {
//    aws = aws.region2
//  }
//}
//
//module "ami_copy_region3" {
//  source            = "git::https://github.com/Chia-Network/terraform-modules.git//ami_copy"
//  source_ami_id     = data.aws_ami.ami.id
//  image_copy_name   = var.image_copy_name
//  source_ami_region = var.region1
//  providers         = {
//    aws = aws.region3
//  }
//}
//
//module "ami_copy_region4" {
//  source            = "git::https://github.com/Chia-Network/terraform-modules.git//ami_copy"
//  source_ami_id     = data.aws_ami.ami.id
//  image_copy_name   = var.image_copy_name
//  source_ami_region = var.region1
//  providers         = {
//    aws = aws.region4
//  }
//}
//
//module "ami_copy_region5" {
//  source            = "git::https://github.com/Chia-Network/terraform-modules.git//ami_copy"
//  source_ami_id     = data.aws_ami.ami.id
//  image_copy_name   = var.image_copy_name
//  source_ami_region = var.region1
//  providers         = {
//    aws = aws.region5
//  }
//}
