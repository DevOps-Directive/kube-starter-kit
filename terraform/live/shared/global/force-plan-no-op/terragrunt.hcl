include "root" {
  # This handles the dynamic backend setup
  path = find_in_parent_folders("root.hcl")
  expose = true
}
