#------------------------------------------------------------------------------
# TeamCity Project Resources
#------------------------------------------------------------------------------
# Projects are containers for build configurations, VCS roots, and settings.
#
# Project hierarchy:
# - _Root (system root project)
#   └── Project A
#       └── Subproject A1
#   └── Project B
#
# Projects can contain:
# - Build configurations
# - VCS roots
# - Parameters
# - SSH keys
# - Connections
# - Versioned settings (Kotlin DSL)
#------------------------------------------------------------------------------

resource "teamcity_project" "this" {
  for_each = var.projects

  name        = each.value.name != "" ? each.value.name : each.key
  id          = local.project_ids[each.key]
  description = each.value.description
  parent_id   = each.value.parent_id
  archived    = each.value.archived

  lifecycle {
    create_before_destroy = true
  }
}

#------------------------------------------------------------------------------
# Project Parameters
#------------------------------------------------------------------------------

resource "teamcity_project_parameter" "this" {
  for_each = {
    for item in flatten([
      for project_key, project in var.projects : [
        for param_key, param_value in project.parameters : {
          key         = "${project_key}-${param_key}"
          project_key = project_key
          param_name  = param_key
          param_value = param_value
        }
      ]
    ]) : item.key => item
  }

  project_id = teamcity_project.this[each.value.project_key].id
  name       = each.value.param_name
  value      = each.value.param_value

  depends_on = [
    teamcity_project.this
  ]
}

#------------------------------------------------------------------------------
# Project ID Mapping
#------------------------------------------------------------------------------

locals {
  project_id_map = {
    for key, project in teamcity_project.this : key => project.id
  }
}
