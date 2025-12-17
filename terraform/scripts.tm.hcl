# Terramate scripts for Terraform orchestration
script "terraform" "init" {
  description = "Initialize Terraform"
  job {
    name     = "terraform init"
    commands = [["terraform", "init", "-lock-timeout=5m"]]
  }
}

script "terraform" "validate" {
  description = "Validate Terraform configuration"
  job {
    name = "terraform validate"
    commands = [
      ["terraform", "init", "-lock-timeout=5m"],
      ["terraform", "validate"],
    ]
  }
}

script "terraform" "plan" {
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

script "terraform" "apply" {
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

script "terraform" "destroy" {
  description = "Destroy Terraform resources"
  job {
    name = "terraform destroy"
    commands = [
      ["terraform", "init", "-lock-timeout=5m"],
      ["terraform", "destroy", "-auto-approve", "-lock-timeout=5m"],
    ]
  }
}

script "terraform" "fmt" {
  description = "Format Terraform files"
  job {
    name     = "terraform fmt"
    commands = [["terraform", "fmt", "-recursive"]]
  }
}
