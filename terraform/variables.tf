variable "source_ami_pattern" {
  description = "ami id for copy source typically the one created by packer in a previous step"
  type        = string
  default     = "Public_Bluebox*"
}

variable "region1" {
  description = "AWS Region for first deployment"
  type        = string
  default     = "us-west-2"
}

variable "region2" {
  description = "AWS Region for second deployment"
  type        = string
  default     = "us-east-1"
}

variable "region3" {
  description = "AWS Region for third deployment"
  type        = string
  default     = "ap-southeast-1"
}

variable "region4" {
  description = "AWS Region for fourth deployment"
  type        = string
  default     = "eu-west-2"
}

variable "region5" {
  description = "AWS Region for fifth deployment"
  type        = string
  default     = "ap-northeast-1"
}

variable "image_copy_name" {
  description = "name to assign to copied images"
  type        = string
  default     = "Public_Bluebox_Base"
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket"
  type = string
  default = ""
}

variable "s3_bucket_key" {
  description = "Path in the bucket for the state"
  type = string
  default = ""
}

variable "s3_bucket_region" {
  description = "Region of the S3 bucket"
  type = string
  default = ""
}
