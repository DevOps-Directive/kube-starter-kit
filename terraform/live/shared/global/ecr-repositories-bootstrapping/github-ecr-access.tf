# This could move into its own module if additional instances are needed are needed
module "iam_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "6.2.1"

  name_prefix = "${module.label.id}-ecr-push"
  path        = "/"
  description = "Enable push access to all us-west-2 ECR repos in this AWS account"

  policy = <<-EOF
    {
        "Version":"2012-10-17",		 	 	 
        "Statement": [
            {
              "Effect": "Allow",
              "Action": "ecr:GetAuthorizationToken",
              "Resource": "*"
            },        
            {
                "Effect": "Allow",
                "Action": [
                    "ecr:CompleteLayerUpload",
                    "ecr:UploadLayerPart",
                    "ecr:InitiateLayerUpload",
                    "ecr:BatchCheckLayerAvailability",
                    "ecr:PutImage"
                ],
                "Resource": "arn:aws:ecr:us-east-2:857059614049:repository/*"
            }
        ]
    }
  EOF
}

module "github-oidc-provider" {
  source  = "terraform-module/github-oidc-provider/aws"
  version = "2.2.1"

  role_name = "${module.label.id}-github-oidc"

  create_oidc_provider = true
  create_oidc_role     = true

  repositories              = ["DevOps-Directive/kube-starter-kit"]
  oidc_role_attach_policies = [module.iam_policy.arn]
}
