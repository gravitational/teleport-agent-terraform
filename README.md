# `teleport-agent-terraform`

This repo contains a reference Terraform module which configures a Teleport agent for providing access to remote resources via reverse tunnel.

## Example module usage

Write this content to `main.tf` in the directory where you want to keep your Terraform configs.

```terraform
module "teleport-agent-terraform" {
  # source
  source = "github.com/gravitational/teleport-agent-terraform"

  # Teleport Agent name is a unique agent name to identify the individual instance.
  # If using the Teleport SSH service, this will also be the public "nodename" of the server# # which appears in `tsh ls`.
  # This cannot be changed later, so pick something descriptive
  teleport_agent_name = "db-agent-1"

  # SSH key name to provision instances with
  # This must be a key that already exists in the AWS account
  key_name = "ops"

  # AMI ID to use
  # Agents should always use OSS AMIs - Enterprise AMIs are not required.
  # See https://github.com/gravitational/teleport/blob/master/examples/aws/terraform/AMIS.md
  ami_id = "ami-072f618d7d3e05cfc"

  # List of AZs to spawn agent instances in
  # Note that Teleport application access does not yet de-duplicate available applications, so
  # will show multiple copies of the same application for access if multiple replicas are used.
  # e.g. ["us-east-1a", "us-east-1d"]
  # This must match the region specified in your provider.tf file
  az_list = ["us-east-1c", "us-east-1d"]

  # VPC ID to deploy the agent into
  # This must have subnets created in the AZs you declared above
  vpc_id = "vpc-1234561234"

  # Instance type used for agent autoscaling group
  agent_instance_type = "t3.medium"

  # AWS KMS alias used for encryption/decryption, defaults to alias used in SSM
  kms_alias_name = "alias/aws/ssm"

  # Account ID which owns the AMIs used to spin up instances
  # You should only need to set this if you're building your own AMIs.
  #ami_owner_account_id = "123456789012"
}
```

Once this file is written, run `terraform init -upgrade && terraform plan && terraform apply`

## Prerequisites

We recommend familiarizing yourself with the following resources prior to reviewing our Terraform examples:

- [Teleport Architecture](https://goteleport.com/docs/architecture/overview/)
- [Admin Guide](https://goteleport.com/docs/admin-guide/)

In order to spin up AWS resources using these Terraform examples, you need the following software:

- terraform v0.13+ [install docs](https://learn.hashicorp.com/terraform/getting-started/install.html)
- awscli v1.14+ [install docs](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)

## How to get help

If you're having trouble, check out [Teleport discussions](ttps://github.com/gravitational/teleport/discussions).

## Public Teleport AMI IDs

Please [see the AMIS.md file](https://github.com/gravitational/teleport/blob/master/examples/aws/terraform/AMIS.md) for a list of public Teleport AMI IDs that you can use.
