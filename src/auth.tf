#------------------------------------------------------------------------------
# TeamCity Authentication Configuration
#------------------------------------------------------------------------------
# Manages authentication modules for TeamCity.
#
# Supported authentication types:
# - built-in: TeamCity's native username/password authentication
# - github: GitHub OAuth authentication
# - gitlab: GitLab OAuth authentication  
# - bitbucket: Bitbucket OAuth authentication
# - google: Google OAuth authentication
# - ldap: LDAP/Active Directory authentication
#
# Multiple authentication modules can be enabled simultaneously.
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Built-in Authentication
#------------------------------------------------------------------------------

resource "teamcity_auth_settings" "builtin" {
  for_each = {
    for k, v in var.auth_modules : k => v
    if v.type == "built-in"
  }

  allow_guest              = false
  guest_username           = "guest"
  welcome_text             = ""
  collapse_login_form      = false
  per_project_permissions  = true
  email_verification       = false

  modules = {
    token = {
      enabled = true
    }
    built_in = {
      enabled = true
    }
  }
}

#------------------------------------------------------------------------------
# GitHub OAuth Authentication
#------------------------------------------------------------------------------

resource "teamcity_auth_settings" "github" {
  for_each = {
    for k, v in var.auth_modules : k => v
    if v.type == "github"
  }

  allow_guest              = false
  per_project_permissions  = true

  modules = {
    token = {
      enabled = true
    }
    built_in = {
      enabled = true
    }
    github_com = {
      enabled              = true
      client_id            = each.value.client_id
      client_secret        = each.value.client_secret
      allow_creating_users = each.value.allow_creating_users
    }
  }
}

#------------------------------------------------------------------------------
# Notes on Authentication Configuration
#------------------------------------------------------------------------------
# The TeamCity provider supports various authentication modules.
# For complex setups with multiple OAuth providers, you may need to
# configure them through the TeamCity UI first, then import the 
# configuration into Terraform.
#
# Common authentication patterns:
#
# 1. Built-in only (for isolated/testing environments)
# 2. Built-in + GitHub OAuth (for GitHub-centric organizations)
# 3. Built-in + LDAP (for enterprise environments)
# 4. Built-in + Multiple OAuth (for maximum flexibility)
#
# Always keep built-in authentication enabled as a fallback!
#------------------------------------------------------------------------------
