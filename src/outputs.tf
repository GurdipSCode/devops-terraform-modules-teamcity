#------------------------------------------------------------------------------
# TeamCity Terraform Module - Outputs
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Server Outputs
#------------------------------------------------------------------------------

output "server_url" {
  description = "The configured TeamCity server URL."
  value       = var.teamcity_host
}

#------------------------------------------------------------------------------
# User Outputs
#------------------------------------------------------------------------------

output "user_ids" {
  description = "Map of user keys to their TeamCity IDs."
  value       = local.user_id_map
}

output "user_details" {
  description = "Detailed information about each user (excluding passwords)."
  value = {
    for key, user in teamcity_user.this : key => {
      id       = user.id
      username = user.username
      name     = user.name
      email    = user.email
    }
  }
}

#------------------------------------------------------------------------------
# Group Outputs
#------------------------------------------------------------------------------

output "group_ids" {
  description = "Map of group keys to their TeamCity IDs."
  value       = local.group_id_map
}

output "group_details" {
  description = "Detailed information about each group."
  value = {
    for key, group in teamcity_group.this : key => {
      id          = group.id
      key         = group.key
      name        = group.name
      description = group.description
    }
  }
}

#------------------------------------------------------------------------------
# Role Outputs
#------------------------------------------------------------------------------

output "custom_role_ids" {
  description = "Map of custom role keys to their TeamCity IDs."
  value = {
    for key, role in teamcity_role.this : key => role.id
  }
}

#------------------------------------------------------------------------------
# Project Outputs
#------------------------------------------------------------------------------

output "project_ids" {
  description = "Map of project keys to their TeamCity IDs."
  value       = local.project_id_map
}

output "project_details" {
  description = "Detailed information about each project."
  value = {
    for key, project in teamcity_project.this : key => {
      id          = project.id
      name        = project.name
      description = project.description
      parent_id   = project.parent_id
      archived    = project.archived
      url         = "${var.teamcity_host}/project/${project.id}"
    }
  }
}

#------------------------------------------------------------------------------
# VCS Root Outputs
#------------------------------------------------------------------------------

output "vcs_root_ids" {
  description = "Map of VCS root keys (project/vcs) to their TeamCity IDs."
  value       = local.vcs_root_id_map
}

output "vcs_root_details" {
  description = "Detailed information about each VCS root (excluding credentials)."
  value = {
    for key, vcs in teamcity_vcsroot.this : key => {
      id         = vcs.id
      name       = vcs.name
      project_id = vcs.project_id
    }
  }
}

#------------------------------------------------------------------------------
# Connection Outputs
#------------------------------------------------------------------------------

output "connection_ids" {
  description = "Map of connection keys to their TeamCity IDs."
  value       = local.connection_id_map
}

#------------------------------------------------------------------------------
# Agent Pool Outputs
#------------------------------------------------------------------------------

output "agent_pool_ids" {
  description = "Map of agent pool keys to their TeamCity IDs."
  value       = local.agent_pool_id_map
}

output "agent_pool_details" {
  description = "Detailed information about each agent pool."
  value = {
    for key, pool in teamcity_agent_pool.this : key => {
      id         = pool.id
      name       = pool.name
      max_agents = pool.max_agents
    }
  }
}

#------------------------------------------------------------------------------
# Summary Output
#------------------------------------------------------------------------------

output "summary" {
  description = "Summary of all created resources."
  value = {
    server_url = var.teamcity_host
    users = {
      count     = length(teamcity_user.this)
      usernames = [for u in teamcity_user.this : u.username]
    }
    groups = {
      count = length(teamcity_group.this)
      names = [for g in teamcity_group.this : g.name]
    }
    custom_roles = {
      count = length(teamcity_role.this)
      names = [for r in teamcity_role.this : r.name]
    }
    projects = {
      count = length(teamcity_project.this)
      names = [for p in teamcity_project.this : p.name]
    }
    vcs_roots = {
      count = length(teamcity_vcsroot.this)
      names = [for v in teamcity_vcsroot.this : v.name]
    }
    agent_pools = {
      count = length(teamcity_agent_pool.this)
      names = [for a in teamcity_agent_pool.this : a.name]
    }
  }
}

#------------------------------------------------------------------------------
# URL Outputs
#------------------------------------------------------------------------------

output "project_urls" {
  description = "Map of project keys to their TeamCity web URLs."
  value = {
    for key, project in teamcity_project.this : key => "${var.teamcity_host}/project/${project.id}"
  }
}

output "admin_urls" {
  description = "Useful TeamCity administration URLs."
  value = {
    users        = "${var.teamcity_host}/admin/admin.html?item=users"
    groups       = "${var.teamcity_host}/admin/admin.html?item=groups"
    roles        = "${var.teamcity_host}/admin/admin.html?item=roles"
    projects     = "${var.teamcity_host}/admin/admin.html?item=projects"
    agents       = "${var.teamcity_host}/agents.html"
    agent_pools  = "${var.teamcity_host}/admin/admin.html?item=agentPools"
    global_settings = "${var.teamcity_host}/admin/admin.html?item=serverConfigGeneral"
  }
}
