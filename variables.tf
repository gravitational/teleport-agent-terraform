# Teleport agent name is a unique name to identify the individual agent instance.
variable "teleport_agent_name" {
  type = string
}

# Teleport proxy hostname/port to connect the agent to - this must include a web UI port like :443 or :3080
# Any security groups and networking for your agent must permit outbound traffic to flow to this host/port,
# as well as to the configured reverse tunnel port for the cluster (defaults to 3024, but can also be multiplexed on 443/3080)
# Don't include https:// in the URL. Any SSL/TLS certificates presented must use valid chains.
variable "teleport_proxy_hostname" {
  type = string
}

# Join token to use to join the Teleport cluster
# This token must already be configured on your cluster and be valid for all Teleport services which the agent is providing access to.
# i.e. to provide database, application and node/SSH access, the token should be created with
# tctl tokens add --type=db,app,node
variable "teleport_join_token" {
  type = string
}

# Agent settings
# DB
variable "teleport_agent_db_enabled" {
  type = string
}

variable "teleport_agent_db_description" {
  type = string
}

### Notes on labels:
### Labels cannot contain the pipe character '|' - this is used to delimit each key:value static label entry.
### Use a string like "env: dev|mode: agent" to add both "env: dev" and "mode: agent" static labels.
### Dynamic labels/commands cannot be configured using this module.
variable "teleport_agent_db_labels" {
  type = string
}

variable "teleport_agent_db_name" {
  type = string
}

variable "teleport_agent_db_redshift_cluster_id" {
  type = string
}

variable "teleport_agent_db_region" {
  type = string
}

variable "teleport_agent_db_protocol" {
  type = string
}

variable "teleport_agent_db_uri" {
  type = string
}

# IAM role for Database agents
# If set, this will automatically provision an instance IAM role which allows RDS database token generation.
# This value can be found under "Resource ID" on the "Configuration" tab of the RDS console.
# If not set, the instance profile will be blank and you will need to configure your own role/instance profi
variable "teleport_agent_db_iam_resource_id" {
  type = string
}

# If set, this will limit the allowed database users for token generation to the specified username string.
# If not set, this will allow RDS token generation for all database users (*)
variable "teleport_agent_db_iam_db_username" {
  type = string
}

# App
variable "teleport_agent_app_enabled" {
  type = string
}

variable "teleport_agent_app_description" {
  type = string
}

### Notes on labels:
### Labels cannot contain the pipe character '|' - this is used to delimit each key:value static label entry.
### Use a string like "env: dev|mode: agent" to add both "env: dev" and "mode: agent" static labels.
### Dynamic labels/commands cannot be configured using this module.
variable "teleport_agent_app_labels" {
  type = string
}

variable "teleport_agent_app_insecure_skip_verify" {
  type = string
}

variable "teleport_agent_app_name" {
  type = string
}

variable "teleport_agent_app_public_addr" {
  type = string
}

variable "teleport_agent_app_uri" {
  type = string
}

# SSH
variable "teleport_agent_ssh_enabled" {
  type = string
}

### Notes on labels:
### Labels cannot contain the pipe character '|' - this is used to delimit each key:value static label entry.
### Use a string like "env: dev|mode: agent" to add both "env: dev" and "mode: agent" static labels.
### Dynamic labels/commands cannot be configured using this module.
variable "teleport_agent_ssh_labels" {
  type = string
}

# SSH key name to provision instances with (used for emergency SSH access)
# This must be a key that already exists in the AWS account
variable "key_name" {
  type = string
}

# AMI ID to use
# Agents should always use OSS AMIs - Enterprise AMIs are not required.
# See https://github.com/gravitational/teleport/blob/master/examples/aws/terraform/AMIS.md
variable "ami_id" {
  type = string
}

# List of subnets to spawn agent instances in
# Note that Teleport application access does not yet de-duplicate available applications, so
# will show multiple copies of the same application for access if multiple replicas are used.
# e.g. ["subnet-abc123abc123", "subnet-abc456abc456"]
# These subnet IDs must exist in the region specified in your provider.tf file
variable "subnet_ids" {
  type = set(string)
}

# Instance type used for agent autoscaling group
variable "agent_instance_type" {
  type    = string
  default = "m4.large"
}

# AWS KMS alias used for encryption/decryption, defaults to alias used in SSM
variable "kms_alias_name" {
  default = "alias/aws/ssm"
}

# Account ID which owns the AMIs used to spin up instances
# You should only need to change this if you're building your own AMIs for testing purposes.
# The default is "126027368216" (Gravitational/Teleport's AMI hosting account)
variable "ami_owner_account_id" {
  type    = string
  default = "126027368216"
}