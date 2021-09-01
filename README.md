# Creating a Bluebox Timelord

This repository contains the necessary code to build a custom Amazon, EBS-backed Ubuntu AMI, Amazon Machine Image.
The image contains a configured installation of the Chia-blockchain code. The config.yaml file for chia-blockchain
is configured to start a Bluebox timelord on boot. For information on Timelords and Blueboxes,
please see the [wiki page](https://github.com/Chia-Network/chia-blockchain/wiki/Timelords).

## How the image is created

There are various elements that are required to build the AMI.
GitHub Actions is used to provide automated workflows, allowing sequenced steps to take place.
HashiCorp's Packer and Terraform are used for building the image and deploying the image
to multiple regions in AWS. Lastly, Ansible is used to provision the image, installing software
and dependencies, and allow for custom configuration.

###### Developing the Packer Template

While packer can be used to create images for other platforms, we are building it for AWS
using JSON. In the bluebox_base.json file, we are specifying the information that is needed
for the builders to create the image. The main items for this are the region, type, source image
information, name, description for the new image, and calling the ansible playbook.

###### Ansible

The main components for Ansible include a group variables directory and playbook.
The group variables yaml file contains the variables that are going to be used to preferentially replace
the default variables in the chia-blockchain config file. This is how we
explicitly configure running a timelord, more specifically, a bluebox. In our code, the
playbook file is going to be used to call pre-existing roles, previously created by the
Chia team, and are located in this [repository](https://github.com/Chia-Network/ansible-roles). Of all 
the roles that are contained in that repository, we are only calling five of them: unattended-upgrades,
apt-update, git, python, and chia-blockchain, installing the software and updating.

###### Terraform

The terraform file is used to copy the image from the origin region to any additional regions that
are specified. By default, we are copying the image from us-west-2 to the following regions:

- us-west-2 (Oregon)
- us-east-1 (N. Virginia)
- ap-northeast-1 (Tokyo)
- ap-southeast-1 (Singapore)
- eu-west-2 (London)

To copy the AMI over to the other regions, we call on a Chia-created module, ami-copy, which is publicly accessible.

###### GitHub Actions

We have configured automated workflows, made up of various jobs that run with GitHub Actions. The YAML
file contains the instructions to run packer for building the AMI, installing software, and using terraform.
We have instructed GitHub Actions to run on our public kubernetes containers. By default, the actions
run on a VM from GitHub, where the operating system can be specified. Alongside the main workflow,
we also run the 'terraform plan' command in a separate workflow, when new commits are pushed to any branch
other than main. This allows the plan to run, viewable in GitHub, and any issues to be identified
prior to the merge to the main branch.

## The Current Status of the Image

This image has been currently deployed to all five of the regions (listed above in the terraform section). The image is publicly available for use
in AWS. If a forked version of this image is desired, this repository can be forked and changes made to it.

# Deploying the Image to EC2 Instances
The quickest and easiest way to get a Bluebox Timelord running in AWS will be to manually create one or more 
EC2 instances using the existing AMI "public_bluebox_image".

If not already done, create an AWS account. There are various options for creating one or more
instances in AWS:
- *Create an instance with on-demand pricing.* This type is going to be more costly, but it has
  reliability compared to spot. As the Blueboxes do not need high availability, an on-demand instance
  is not recommended.
- *Create an instance with spot pricing.* This type is typically cheaper than the
  on-demand pricing. However, there is a greater chance for this instance to be interrupted if total
  demand is increased, either by price increases or availability. In the EC2 service tab, go to Instances ->
  Spot Requests.
- *Create instances with an autoscaling group, with spot pricing constraints.* This allows for
  automatic deployment of a specified number of instances, in specific regions and availability zones,
  and for specific types. For specific steps on creating the ASG in AWS using the web GUI, proceed to 
  [ASG with Spot Instances](https://aws.amazon.com/getting-started/hands-on/ec2-auto-scaling-spot-instances/) .


If you are unfamiliar with the process for creating EC2 instances, please refer to this [AWS tutorial](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/EC2_GetStarted.html)
Proceed to the section below for guidance on instance types.

Make sure that assigned security allows for ingress traffic on port 8444, for the full node, and port 22, allowing
SSH connectivity. Also, ensure that the SSH keys are saved.
###### Instance Types

The CPU for the Bluebox is not required to be as fast as a normal Timelord, but the vdf client
process is still demanding. There are a few things to be aware of when deciding which type of
instance to use for the Blueboxes:
- The amount storage will need to be enough for the operating system and the blockchain database.
  The database file, as of 8/25/2021, is approximately 14GB, and consistently increasing.
  Therefore, ensure that enough storage is available to support this.
- The T* general-purpose instances have CPU credits associated with them. They are not intended to be
  used for CPU-intensive operations for long periods of time. This type of instance defaults to unlimited
  billing for the CPU, therefore, it is possible to exhaust the number of credits in a short period, resulting in additional incurred charges. If there is a desire to run the T* instances,
  the billing can be switched from unlimited to standard.
- As discussed in the Chia-blockchain [Wiki page - Timelords](https://github.com/Chia-Network/chia-blockchain/wiki/Timelords), the process_count for the vdf clients should be
  properly adjusted based on CPU performance. This can be evaluated while the bluebox is running, by monitoring
  the resources. The default process_count in the chia-blockchain config.yml is set to 3. However,
  we have set the process_count to 2 in this image.
  - After testing with a variety of CPUs, we have found a general rule-of-thumb of setting one process_count
    (vdf client process) for every two CPU that support hyperthreading.

###### Finding the AMI in AWS

The name of the instance in AWS is "Public Bluebox Base- (Timestamp)". As new versions of the image
are built, the timestamp value and the AMI ID will change.

###### Items That Need to be Updated for Building and Deploying a Custom AMI

- [S3 Bucket Name](https://github.com/Chia-Network/public_bluebox_image/blob/733d932f9db26227443cb2153b99304787319a48/.github/workflows/workflow.yml#L67) - 
  Located in .github -> workflows -> workflow.yml.This is used to store the state file. This needs to be changed to a
  different, accessible file path.
- ["Get ephemeral aws credentials"](https://github.com/Chia-Network/public_bluebox_image/blob/733d932f9db26227443cb2153b99304787319a48/.github/workflows/workflow.yml#L36) step - Located in .github -> workflows -> workflow.yml.
  This step needs to be replaced with your own credentials. Recommend using the actions in this [repo](https://github.com/aws-actions/configure-aws-credentials).
- [k8s-public](https://github.com/Chia-Network/public_bluebox_image/blob/733d932f9db26227443cb2153b99304787319a48/.github/workflows/workflow.yml#L9) -
  Located in .github -> workflows -> workflow.yml & tfplan.yml. This runner is for internal use only. A default AWS Linux runner can be
  specified, such as ubuntu:latest. 
###### Things to Note

- Any users who run the image will need to either sync the blockchain database, or pull their own copy of the 
  database. Chia will not be providing a source of this database.
- The Chia Network will not be responsible for any incurred charges. While we are providing some tips and
  guidance on creating EC2 instances, it is the user's responsible to ensure proper configuration and monitor
  the costs of instances.

## Using Terraform to Automate the Deployment

For those who are interested in using Terraform for deploying to AWS, a Terraform folder, named
"terraform_deploy_example", is available to use as a template. There will also be a GitHub folder, where a workflow 
file can be viewed.

There are some assumptions to make when utilizing the code that we have in the *.tf files:
- The code is written to be used with GitHub Actions. There are other services available, such as Azure 
  DevOps and GitLab CI/CD.

  *Note: The Terraform code can be ran locally on a user's machine and not using a CI/CD pipeline. This will 
  require the installation of Terraform to be performed on the local machine.*
- There will be some variables that will be provided a value, including the security group, key name,
  iam instance profile, and S3 bucket name. However, these will need to be populated with values that
  are unique to you.
