# Used in role ARNs
data "aws_caller_identity" "current" {}

# Used to access provider region
data "aws_region" "current" {}
