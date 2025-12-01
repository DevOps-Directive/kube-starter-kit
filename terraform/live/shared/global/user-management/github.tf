resource "github_team" "admin" {
  name    = "Admin"
  privacy = "closed"
}

resource "github_team" "read_only" {
  name    = "ReadOnly"
  privacy = "closed"
}

locals {
  github_teams_by_key = {
    Admin    = github_team.admin.id
    ReadOnly = github_team.read_only.id
  }
}

resource "github_team_repository" "kube_starter_kit_admin_team" {
  team_id    = github_team.admin.id
  repository = "kube-starter-kit"
  permission = "admin"
}

resource "github_team_repository" "kube_starter_kit_readonly_team" {
  team_id    = github_team.read_only.id
  repository = "kube-starter-kit"
  permission = "pull"
}

resource "github_membership" "org" {
  for_each = local.github_users

  username = each.value.username
  role     = each.value.org_role
}

resource "github_team_membership" "team" {
  for_each = local.github_team_memberships

  team_id  = local.github_teams_by_key[each.value.team_key]
  username = each.value.username
  role     = each.value.team_role
}
