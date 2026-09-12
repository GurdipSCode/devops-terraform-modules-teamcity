#------------------------------------------------------------------------------
# TeamCity Agent Pool Resources
#------------------------------------------------------------------------------
# Agent pools organize build agents and control which projects can use them.
#
# Pool features:
# - Group agents by capability (OS, tools, etc.)
# - Limit which projects can use specific agents
# - Set maximum agent limits per pool
#
# Default pool:
# - All agents start in the "Default" pool
# - Agents can be moved between pools via UI or API
#------------------------------------------------------------------------------

resource "teamcity_agent_pool" "this" {
  for_each = var.agent_pools

  name       = each.value.name
  max_agents = each.value.max_agents

  lifecycle {
    create_before_destroy = true
  }
}

#------------------------------------------------------------------------------
# Agent Pool Project Assignments
#------------------------------------------------------------------------------

resource "teamcity_agent_pool_project" "this" {
  for_each = {
    for item in flatten([
      for pool_key, pool in var.agent_pools : [
        for project_id in pool.project_ids : {
          key        = "${pool_key}-${project_id}"
          pool_key   = pool_key
          project_id = project_id
        }
      ]
    ]) : item.key => item
  }

  pool_id    = teamcity_agent_pool.this[each.value.pool_key].id
  project_id = each.value.project_id

  depends_on = [
    teamcity_agent_pool.this,
    teamcity_project.this
  ]
}

#------------------------------------------------------------------------------
# Agent Pool ID Mapping
#------------------------------------------------------------------------------

locals {
  agent_pool_id_map = {
    for key, pool in teamcity_agent_pool.this : key => pool.id
  }
}
