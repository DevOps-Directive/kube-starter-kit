# Inputs from networking stack
input "vpc_id" {
  backend       = "terraform"
  from_stack_id = "staging-use2-networking"
  value         = outputs.vpc_id.value
  mock          = "vpc-mock-12345"
}

input "vpc_cidr" {
  backend       = "terraform"
  from_stack_id = "staging-use2-networking"
  value         = outputs.vpc_cidr.value
  mock          = "10.0.0.0/16"
}

input "private_subnets" {
  backend       = "terraform"
  from_stack_id = "staging-use2-networking"
  value         = outputs.private_subnets.value
  mock          = ["subnet-mock-1", "subnet-mock-2", "subnet-mock-3"]
}

# Inputs from bootstrapping stack
input "route53_zone_arn" {
  backend       = "terraform"
  from_stack_id = "staging-gbl-bootstrapping"
  value         = outputs.zone_arn.value
  mock          = "arn:aws:route53:::hostedzone/MOCKHOSTEDZIONEID"
}
