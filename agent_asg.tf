# Agent auto scaling group to provide highly available copies of Teleport agents.
resource "aws_autoscaling_group" "agent" {
  #name                      = "${var.teleport_agent_name}-agent"
  max_size                  = 1000
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "EC2"
  desired_capacity          = length(var.subnet_ids)
  force_delete              = false
  launch_configuration      = aws_launch_configuration.agent.name
  vpc_zone_identifier       = [for subnet in data.aws_subnet.agent : subnet.id]

  tag {
    key                 = "TeleportProxyHostname"
    value               = var.teleport_proxy_hostname
    propagate_at_launch = true
  }

  tag {
    key                 = "TeleportRole"
    value               = "agent"
    propagate_at_launch = true
  }

  // external autoscale algos can modify these values,
  // so ignore changes to them
  lifecycle {
    ignore_changes = [
      desired_capacity,
      max_size,
      min_size,
    ]
  }
}

resource "aws_launch_configuration" "agent" {
  lifecycle {
    create_before_destroy = true
  }
  name_prefix                 = "${var.teleport_agent_name}-agent-"
  image_id                    = var.ami_id
  instance_type               = var.agent_instance_type
  user_data                   = templatefile(
    "${path.module}/agent-user-data.tpl",
    {
      region                                  = data.aws_region.current.name
      teleport_agent_name                     = var.teleport_agent_name
      teleport_proxy_hostname                 = var.teleport_proxy_hostname
      teleport_join_token                     = var.teleport_join_token
      teleport_agent_db_enabled               = var.teleport_agent_db_enabled
      teleport_agent_db_description           = var.teleport_agent_db_description
      teleport_agent_db_labels                = var.teleport_agent_db_labels
      teleport_agent_db_name                  = var.teleport_agent_db_name
      teleport_agent_db_redshift_cluster_id   = var.teleport_agent_db_redshift_cluster_id
      teleport_agent_db_region                = var.teleport_agent_db_region
      teleport_agent_db_protocol              = var.teleport_agent_db_protocol
      teleport_agent_db_uri                   = var.teleport_agent_db_uri
      teleport_agent_app_enabled              = var.teleport_agent_app_enabled
      teleport_agent_app_description          = var.teleport_agent_app_description
      teleport_agent_app_insecure_skip_verify = var.teleport_agent_app_insecure_skip_verify
      teleport_agent_app_labels               = var.teleport_agent_app_labels
      teleport_agent_app_name                 = var.teleport_agent_app_name
      teleport_agent_app_public_addr          = var.teleport_agent_app_public_addr
      teleport_agent_app_uri                  = var.teleport_agent_app_uri
      teleport_agent_ssh_enabled              = var.teleport_agent_ssh_enabled
      teleport_agent_ssh_labels               = var.teleport_agent_ssh_labels
    }
  )
  key_name                    = var.key_name
  associate_public_ip_address = false
  security_groups             = [for s in aws_security_group.agent: s.id]
  iam_instance_profile        = aws_iam_instance_profile.agent.id
}
