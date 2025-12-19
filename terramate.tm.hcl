terramate {
  required_version = ">= 0.10.0"

  config {
    git {
      default_branch = "main"
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
