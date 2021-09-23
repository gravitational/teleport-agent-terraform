# // Node subnets are for teleport nodes joining the cluster
# // Nodes are not accessible via internet and are accessed
# // via emergency access bastions or proxies
# resource "aws_route_table" "agent" {
#   for_each  = var.az_list

#   vpc_id    = data.aws_vpc.teleport.id
#   tags = {
#     Name            = "teleport-agent-${each.key}"
#     TeleportAgent   = var.teleport_agent_name
#   }
# }

# // Route all outbound traffic through NAT gateway
# resource "aws_route" "agent" {
#   for_each               = aws_route_table.agent

#   route_table_id         = each.value.id
#   destination_cidr_block = "0.0.0.0/0"
#   nat_gateway_id         = aws_nat_gateway.teleport[each.key].id
#   depends_on             = [aws_route_table.agent]
# }

# resource "aws_subnet" "agent" {
#   for_each          = var.az_list

#   vpc_id            = data.aws_vpc.teleport.id
#   cidr_block        = cidrsubnet(local.node_cidr, 4, var.az_number[substr(each.key, 9, 1)])
#   availability_zone = each.key
#   tags = {
#     Name            = "teleport-agent-${each.key}"
#     TeleportAgent   = var.teleport_agent_name
#   }
# }

# resource "aws_route_table_association" "agent" {
#   for_each       = aws_subnet.agent

#   subnet_id      = each.value.id
#   route_table_id = aws_route_table.agent[each.key].id
# }

// Agent security groups only allow inbound SSH access.
resource "aws_security_group" "agent" {
  for_each = data.aws_subnet.agent

  vpc_id = each.value.vpc_id
  tags = {
    TeleportAgent = var.teleport_agent_name
  }
}

resource "aws_security_group_rule" "allow_inbound_ssh" {
  for_each = aws_security_group.agent

  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  prefix_list_ids   = []
  security_group_id = each.value.id
}

resource "aws_security_group_rule" "allow_outbound_all" {
  for_each = aws_security_group.agent

  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  prefix_list_ids   = []
  security_group_id = each.value.id
}
