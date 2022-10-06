# Set DB region if explicitly configured, otherwise assume it's the same as the region where the agent is deployed
# Set DB user if explicitly configured, otherwise allow permission for all users ("*")
locals {
  db_region = var.teleport_agent_db_region != "" ? var.teleport_agent_db_region : data.aws_region.current.name
  db_user   = var.teleport_agent_db_iam_db_username != "" ? var.teleport_agent_db_iam_db_username : "*"
}

# Configures IAM role for database
resource "aws_iam_role" "agent" {
  name = "${var.teleport_agent_name}-role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {"Service": "ec2.amazonaws.com"},
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF

}

# The role and instance profile need to be created regardless for Terraform to remain happy, but this
# inline policy granting RDS token generation access is only created if a resource ID is set in the module variables.
resource "aws_iam_role_policy" "agent" {
  name = "${var.teleport_agent_name}-role-policy"
  role = aws_iam_role.agent.id

  count = var.teleport_agent_db_iam_resource_id != "" ? 1 : 0

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "rds-db:connect"
            ],
            "Resource": [
                "arn:aws:rds-db:${local.db_region}:${data.aws_caller_identity.current.account_id}:dbuser:${var.teleport_agent_db_iam_resource_id}/${local.db_user}"
            ]
        }
    ]
}
EOF

}

# Configures IAM instance profile associated with agents
resource "aws_iam_instance_profile" "agent" {
  name       = "${var.teleport_agent_name}-instance-profile"
  role       = aws_iam_role.agent.name
  depends_on = [aws_iam_role_policy.agent]
}