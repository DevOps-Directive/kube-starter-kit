terramate {
  required_version = ">= 0.15.0"

  config {
    git {
      default_branch = "main"
    }

    change_detection {
      git {
        untracked   = "off"
        uncommitted = "off"
      }
      terraform {
        enabled = true  # Detect module changes
      }
    }

    cloud {
      organization = "devops-directive"
      location     = "us"
    }

    run {
      env {
        TF_PLUGIN_CACHE_DIR = "${terramate.root.path.fs.absolute}/.tf_plugin_cache_dir"
      }
    }

    # Enable experimental features
    experiments = [
      "outputs-sharing",
      "scripts",
      "tmgen",
    ]
  }
}
