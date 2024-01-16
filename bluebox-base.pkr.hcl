variable "arch" {
  type    = string
  default = "${env("arch")}"
}

variable "chia_ref" {
  type    = string
  default = "${env("chia_ref")}"
}

variable "github_repository" {
  type    = string
  default = "${env("GITHUB_REPOSITORY")}"
}

variable "github_run_id" {
  type    = string
  default = "${env("GITHUB_RUN_ID")}"
}

variable "github_server" {
  type    = string
  default = "${env("GITHUB_SERVER_URL")}"
}

variable "instance_type" {
  type    = string
  default = "${env("instance_type")}"
}

variable "network" {
  type    = string
  default = "${env("network")}"
}

variable "region" {
  type    = string
  default = "${env("region")}"
}

data "amazon-ami" "source" {
  filters = {
    architecture        = "${var.arch}"
    name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04*"
    root-device-type    = "ebs"
    virtualization-type = "hvm"
  }
  most_recent = true
  owners      = ["099720109477"]
  region      = "${var.region}"
}

locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

source "amazon-ebs" "ami" {
  ami_description      = "Public Bluebox Image, built from {{ .SourceAMI }} ({{ .SourceAMIName }}) at ${timestamp()}"
  ami_name             = "Public_Bluebox_Base-${var.network}-${var.arch}-${local.timestamp}"
  iam_instance_profile = "packer-profile"
  instance_type        = "${var.instance_type}"
  launch_block_device_mappings {
    delete_on_termination = true
    device_name           = "/dev/sda1"
    volume_size           = "50"
    volume_type           = "gp3"
  }
  region            = "${var.region}"
  shutdown_behavior = "terminate"
  source_ami        = "${data.amazon-ami.source.id}"
  ssh_username      = "ubuntu"
  tags              = {
    Name         = "Public Bluebox Base ${var.network} ${var.arch} ${local.timestamp}"
    application  = "chia-blockchain"
    arch         = "${var.arch}"
    component    = "bluebox"
    network      = "${var.network}"
    ref          = "${var.chia_ref}"
    repository   = "${var.github_repository}"
    workflow_url = "${var.github_server}/${var.github_repository}/actions/runs/${var.github_run_id}"
  }
}

build {
  sources = ["source.amazon-ebs.ami"]

  provisioner "ansible" {
    ansible_env_vars = ["ansible_python_interpreter=/usr/bin/python3"]
    groups           = ["${var.network}"]
    playbook_file    = "./ansible/playbook.yml"
    use_proxy        = false
    user             = "ubuntu"
    max_retries      = 3
  }
}
