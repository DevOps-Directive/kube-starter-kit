# Shared stage - resources shared across accounts (ECR, IAM Identity Center, etc.)
# Note: terraform_iam_role_arn varies per stack in shared, so it's set at stack level
globals {
  stage = "shared"
}
