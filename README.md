# `teleport-agent-terraform`

> [!IMPORTANT]
> This code in this repo is deprecated.  Please use the code at https://github.com/gravitational/teleport/tree/master/examples/aws/terraform instead.

This repo contains a reference Terraform module which configures a Teleport agent for providing access to remote resources via reverse tunnel.

You can use this module to deploy an agent providing any or all of:
- application access
- database access
- node/SSH access

To provide Kubernetes access to remote clusters via Teleport, see the "Kubernetes clusters" section below.

## Example module usage

Write this content to `main.tf` in the directory where you want to keep your Terraform configs.

```terraform
module "teleport-agent-terraform" {
  # source
  source = "github.com/gravitational/teleport-agent-terraform"

  # Teleport Agent name is a unique agent name to identify the individual instance.
  teleport_agent_name = "teleport-database"

  # Teleport proxy hostname/port to connect the agent to - this must include a web UI port like :443 or :3080
  # Any security groups and networking for your agent must permit outbound traffic to flow to this host/port,
  # as well as to the configured reverse tunnel port for the cluster (defaults to 3024, but can also be multiplexed on 443/3080)
  # Don't include https:// in the URL. Any SSL/TLS certificates presented must use valid chains.
  teleport_proxy_hostname = "teleport.example.com:443"

  # Join token which will allow the agent to join the Teleport cluster.
  # This token must already be configured on your cluster and be valid for all Teleport services which the agent is providing access to.
  # i.e. to provide database, application and node/SSH access, the token should be created with
  # tctl tokens add --type=db,app,node
  # See the Teleport static/dynamic token documentation for more details.
  teleport_join_token = "abc123abc123abc123"

  ### Agent mode settings
  ### Note that all of these variables must have a value configured, even if you are not using that mode.
  ### A blank string ("") should be used to avoid setting them.
  ### Notes on labels:
  ### Labels cannot contain the pipe character '|' - this is used to delimit each key:value static label entry.
  ### Use a string like "env: dev|mode: agent" to add both "env: dev" and "mode: agent" static labels.
  ### Dynamic labels/commands cannot be configured using this module.

  # Database
  teleport_agent_db_enabled = "false"
  teleport_agent_db_description = ""
  teleport_agent_db_labels = ""
  teleport_agent_db_name = ""
  teleport_agent_db_redshift_cluster_id = ""
  teleport_agent_db_region = ""
  teleport_agent_db_protocol = ""
  teleport_agent_db_uri = ""
  # IAM role for Database agents
  # If set, this will automatically provision an instance IAM role which allows RDS database token generation.
  # This value can be found under "Resource ID" on the "Configuration" tab of the RDS console.
  # If not set, the instance profile will be blank and you will need to configure your own role/instance profile.
  teleport_agent_db_iam_resource_id = ""
  # If set, this will limit the allowed database users for token generation to the specified username string.
  # If not set, this will allow RDS token generation for all database users (*)
  teleport_agent_db_iam_db_username = ""

  # App
  teleport_agent_app_enabled = "false"
  teleport_agent_app_description = ""
  teleport_agent_app_labels = ""
  teleport_agent_app_insecure_skip_verify = ""
  teleport_agent_app_name = ""
  teleport_agent_app_public_addr = ""
  teleport_agent_app_uri = ""

  # SSH
  teleport_agent_ssh_enabled = "true"
  teleport_agent_ssh_labels = "env: dev|mode: agent"

  ### Settings for agent deployment
  # List of subnets to spawn agent instances in
  # Note that Teleport application access does not yet de-duplicate available applications, so
  # will show multiple copies of the same application for access if multiple replicas are used.
  # e.g. ["subnet-abc123abc123", "subnet-abc456abc456"]
  # These subnet IDs must exist in the region specified in your provider.tf file
  subnet_ids = ["subnet-abc123abc123", "subnet-abc456abc456"]

  # Instance type used for agent autoscaling group
  agent_instance_type = "t3.medium"

  # SSH key name to provision instances with for emergency access
  # This must be a key that already exists in the AWS account
  key_name = "ops"

  ### Other settings you probably don't need to change
  # AMI ID to use
  # Agents can use OSS AMIs if preferred - Enterprise AMIs are not required.
  # See https://github.com/gravitational/teleport/blob/master/examples/aws/terraform/AMIS.md
  ami_id = "ami-0a96d44f7f99e06c7"
}

```

Once this file is written, run `terraform init -upgrade && terraform plan && terraform apply`

## Prerequisites

We recommend familiarizing yourself with the following resources prior to reviewing our Terraform examples:

- [Teleport Architecture](https://goteleport.com/docs/architecture/overview/)
- [Admin Guide](https://goteleport.com/docs/management/admin/)

In order to spin up AWS resources using these Terraform examples, you need the following software:

- terraform v1.0+ [install docs](https://learn.hashicorp.com/tutorials/terraform/install-cli)
- awscli v1.14+ [install docs](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

## How to get help

If you're having trouble, check out [Teleport discussions](ttps://github.com/gravitational/teleport/discussions).

## Public Teleport AMI IDs

Please [see the AMIS.md file](https://github.com/gravitational/teleport/blob/master/examples/aws/terraform/AMIS.md) for a list of public Teleport AMI IDs that you can use.

## Kubernetes clusters

To provide Kubernetes access to remote clusters, please use the [`teleport-kube-agent`](https://github.com/gravitational/teleport/tree/master/examples/chart/teleport-kube-agent) Helm chart.

Here is a rough example of how to use the Terraform Helm provider to deploy the chart:

```terraform
provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "helm_release" "teleport-kube-agent" {
  name       = "teleport-kube-agent"

  repository = "https://charts.releases.teleport.dev"
  chart      = "teleport-kube-agent"
  version    = "7.1.3"

  set {
    name  = "roles"
    value = "kube"
  }
  # Teleport proxy hostname to connect to
  set {
    name  = "proxyAddr"
    value = "teleport.example.com:443"
  }
  # Join token to use (must be valid for 'kube' service/role)
  set {
    name  = "authToken"
    value = "abc123abc123abc123"
  }
  # Kubernetes cluster name to register with Teleport
  set {
    name  = "kubeClusterName"
    value = "dev-cluster"
  }
}
```

For more detailed use cases, please see the `teleport-kube-agent` README and the Terraform Helm provider docs.
