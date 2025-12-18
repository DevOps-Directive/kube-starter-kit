terramate {
  required_version = ">= 0.10.0"

  config {
    git {
      default_branch = "main"
    }

    # Enable experimental features
    experiments = [
      "outputs-sharing",
      "scripts",
      "tmgen",
    ]
  }
}
