# VPC for Teleport agent deployment
# data "aws_vpc" "teleport" {
#   id                   = var.vpc_id
# }

# Load existing subnets
data "aws_subnet" "agent" {
  for_each = var.subnet_ids

  id = each.key
}
