#------------------------------------------------------------------------------
# TeamCity Connection Resources
#------------------------------------------------------------------------------
# Connections define integrations with external services.
#
# Connection types:
# - github: GitHub OAuth connection
# - github_app: GitHub App connection (recommended)
# - gitlab: GitLab connection
# - bitbucket: Bitbucket connection
# - space: JetBrains Space connection
#
# Connections are typically created on the Root project to be
# available to all subprojects.
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# GitHub App Connections
#------------------------------------------------------------------------------

resource "teamcity_connection" "github_app" {
  for_each = {
    for k, v in var.connections : k => v
    if v.type == "github_app"
  }

  project_id   = "_Root"
  display_name = each.value.display_name

  github_app = {
    app_id         = each.value.app_id
    client_id      = each.value.client_id
    client_secret  = each.value.client_secret
    private_key    = each.value.private_key
    webhook_secret = each.value.webhook_secret
    owner_url      = each.value.owner_url
  }

  lifecycle {
    create_before_destroy = true
  }
}

#------------------------------------------------------------------------------
# GitHub OAuth Connections
#------------------------------------------------------------------------------

resource "teamcity_connection" "github" {
  for_each = {
    for k, v in var.connections : k => v
    if v.type == "github"
  }

  project_id   = "_Root"
  display_name = each.value.display_name

  github = {
    client_id     = each.value.client_id
    client_secret = each.value.client_secret
  }

  lifecycle {
    create_before_destroy = true
  }
}

#------------------------------------------------------------------------------
# GitLab Connections
#------------------------------------------------------------------------------

resource "teamcity_connection" "gitlab" {
  for_each = {
    for k, v in var.connections : k => v
    if v.type == "gitlab"
  }

  project_id   = "_Root"
  display_name = each.value.display_name

  gitlab = {
    url           = each.value.server_url != null ? each.value.server_url : "https://gitlab.com"
    client_id     = each.value.client_id
    client_secret = each.value.client_secret
  }

  lifecycle {
    create_before_destroy = true
  }
}

#------------------------------------------------------------------------------
# Bitbucket Connections
#------------------------------------------------------------------------------

resource "teamcity_connection" "bitbucket" {
  for_each = {
    for k, v in var.connections : k => v
    if v.type == "bitbucket"
  }

  project_id   = "_Root"
  display_name = each.value.display_name

  bitbucket = {
    client_id     = each.value.client_id
    client_secret = each.value.client_secret
  }

  lifecycle {
    create_before_destroy = true
  }
}

#------------------------------------------------------------------------------
# Connection ID Mapping
#------------------------------------------------------------------------------

locals {
  connection_id_map = merge(
    { for k, v in teamcity_connection.github_app : k => v.id },
    { for k, v in teamcity_connection.github : k => v.id },
    { for k, v in teamcity_connection.gitlab : k => v.id },
    { for k, v in teamcity_connection.bitbucket : k => v.id }
  )
}
