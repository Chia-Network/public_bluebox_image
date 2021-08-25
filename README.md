# Creating the Bluebox Image

This repository contains the necessary code to build a custom Amazon, EBS-backed Ubuntu AMI. 
The image contains a configured installation of the Chia-blockchain code. The config.yaml file for chia-blockchain
is configured to start a bluebox timelord on boot.

## How the image is created

There are various elements that are required to build the AMI, or Amazon Machine Image.
GitHub Actions is used to provide automated workflows, allowing sequenced steps to take place.
HashiCorp's Packer and Terraform are used for building the image and deploying the image
to multiple regions in AWS. Lastly, Ansible is used to provision the image, installing software
and dependencies, and allowing for custom configuration.

###### Developing the Packer Template

While packer can be used to create images for other platforms, we are building it for AWS
using JSON. In the bluebox_base.json file, we are specifying the information that is needed
for the builders to create the image. The main items for this are the region, type, source image
information, name, and description for the new image, and calling the ansible playbook.

###### Ansible

The main components for Ansible include a group variables directory and the playbook.
The group variables yaml file contains the variables that are going to be used to preferentially replace
the default variables in the config.yml file, used for the chia-blockchain. This is how we 
explicitly configure running a timelord, more specifically, a bluebox. In our instance the 
playbook file is going to be used to call pre-existing roles that were previously created by the
Chia team and are located here: https://github.com/Chia-Network/ansible-roles. Although that repository
contains a relatively large number of roles, we are only calling five of them: unattended-upgrades,
 apt-update, git, python, and chia-blockchain, installing the software and updating.

###### Terraform

The terraform file is used to copy the image from the origin region to any additional regions that
are specified. By default, we are copying the image from us-west-2 to the following regions:

- us-west-2 (Oregon)
- us-east-1 (N. Virginia)
- ap-northeast-1 (Tokyo)
- ap-southeast-1 (Singapore)
- eu-west-2 (London)

To copy the AMI over to the other regions, we call on Chia created module, which is publicly accessible.

###### Github 
## Settings that will need to be added to use this image



