# Terramate scripts for Terraform orchestration
script "init" {
  description = "Initialize Terraform"
  job {
    name     = "terraform init"
    commands = [["terraform", "init", "-lock-timeout=5m"]]
  }
}

script "lock" {
  description = "Update provider lock file with cross-platform hashes"
  job {
    name = "terraform providers lock"
    commands = [
      ["terraform", "providers", "lock",
        "-platform=linux_amd64",
        "-platform=darwin_amd64",
        "-platform=darwin_arm64",
      ],
    ]
  }
}

script "validate" {
  description = "Validate Terraform configuration"
  job {
    name = "terraform validate"
    commands = [
      ["terraform", "init", "-lock-timeout=5m"],
      ["terraform", "validate"],
    ]
  }
}

script "plan" {
  description = "Plan Terraform changes with outputs sharing"
  job {
    name = "terraform plan"
    commands = [
      ["terraform", "init", "-lock-timeout=5m"],
      ["terraform", "validate"],
      ["terraform", "plan", "-out=tfplan", "-lock=false", {
        enable_sharing = true
        mock_on_fail   = true
      }],
    ]
  }
}

script "preview" {
  name        = "Terraform Deployment Preview"
  description = "Create a preview of Terraform changes and synchronize it to Terramate Cloud"

  job {
    commands = [
      ["terraform", "init", "-lock-timeout=5m"],
      ["terraform", "validate"],
      ["terraform", "plan", "-out", "out.tfplan", "-detailed-exitcode", "-lock=false", {
        sync_preview        = true
        terraform_plan_file = "out.tfplan"
        enable_sharing      = true
        mock_on_fail        = true
      }],
    ]
  }
}

script "apply" {
  description = "Apply Terraform changes with outputs sharing"
  job {
    name = "terraform apply"
    commands = [
      ["terraform", "init", "-lock-timeout=5m"],
      ["terraform", "apply", "-auto-approve", "-lock-timeout=5m", {
        enable_sharing = true
      }],
    ]
  }
}

script "destroy" {
  description = "Destroy Terraform resources"
  job {
    name = "terraform destroy"
    commands = [
      ["terraform", "init", "-lock-timeout=5m"],
      ["terraform", "destroy", "-auto-approve", "-lock-timeout=5m"],
    ]
  }
}

script "fmt" {
  description = "Format Terraform files"
  job {
    name     = "terraform fmt"
    commands = [["terraform", "fmt", "-recursive"]]
  }
}
