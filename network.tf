# VPC for Teleport agent deployment
data "aws_vpc" "teleport" {
  id                   = var.vpc_id
}

# Load existing subnets
# Private subnets
data "aws_subnet" "agent" {
  for_each = var.az_list

  availability_zone = each.key
#   filter {
#     name = "tag:Name"
#     values = ["dev-private-app-*"]
#   }
}
