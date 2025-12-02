locals {
  users_file = yamldecode(file("${path.module}/data/users.yaml"))
  users_list = try(local.users_file.users, [])

  # AWS
  sso_users = {
    for u in local.users_list : u.aws.user_name => u.aws
    if try(u.aws.user_name, null) != null
  }

  account_ids = [
    "857059614049", # ecr repositories
    "094905625236", # infra
    "085164809580", # management
    "964263445142", # production
    "038198578795", # staging
  ]

  # GitHub
  github_users = {
    for u in local.users_file.users :
    u.github.username => {
      username = u.github.username
      org_role = try(u.github.role, "member") # default stays "member"
      teams    = try(u.github.teams, [])      # list of team keys
    }
    if try(u.github.username, null) != null
  }

  github_team_memberships = {
    for tm in flatten([
      for username, user in local.github_users : [
        for team_key, team_cfg in user.teams : {
          key       = "${username}:${team_key}"
          username  = username
          team_key  = team_key
          team_role = try(team_cfg.role, "member") # team: member|maintainer
        }
      ]
    ]) : tm.key => tm
  }
}
