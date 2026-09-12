#------------------------------------------------------------------------------
# TeamCity Terraform Module - Main Configuration
#------------------------------------------------------------------------------
# This module manages JetBrains TeamCity CI/CD server infrastructure including:
# - Global server settings
# - Authentication modules
# - Projects and VCS roots
# - Users and user groups
# - Roles and permissions
# - Cleanup rules
# - Connections (GitHub, GitLab, etc.)
#
# TeamCity Terraform Provider by JetBrains
# https://github.com/JetBrains/terraform-provider-teamcity
#------------------------------------------------------------------------------

terraform {
  required_version = ">= 1.0.0"

  required_providers {
    teamcity = {
      source  = "jetbrains/teamcity"
      version = ">= 0.0.50"
    }
  }
}

#------------------------------------------------------------------------------
# Local Values
#------------------------------------------------------------------------------

locals {
  # Generate project IDs if not provided
  project_ids = {
    for name, project in var.projects :
    name => project.id != "" ? project.id : replace(title(replace(name, "-", " ")), " ", "")
  }

  # Flatten VCS roots from all projects
  vcs_roots_flat = flatten([
    for project_key, project in var.projects : [
      for vcs_key, vcs in project.vcs_roots : {
        key         = "${project_key}/${vcs_key}"
        project_key = project_key
        vcs_key     = vcs_key
        name        = vcs.name != "" ? vcs.name : vcs_key
        type        = vcs.type
        url         = vcs.url
        branch      = vcs.branch
        auth_method = vcs.auth_method
        username    = vcs.username
        password    = vcs.password
        private_key = vcs.private_key
        passphrase  = vcs.passphrase
      }
    ]
  ])

  vcs_roots_map = {
    for vcs in local.vcs_roots_flat : vcs.key => vcs
  }
}
