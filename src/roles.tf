#------------------------------------------------------------------------------
# TeamCity Role Resources
#------------------------------------------------------------------------------
# Roles define sets of permissions that can be assigned to users or groups.
#
# Built-in roles:
# - SYSTEM_ADMIN: Full server administration
# - PROJECT_ADMIN: Full project administration
# - PROJECT_DEVELOPER: Run builds, view configurations
# - PROJECT_VIEWER: View-only access
#
# Custom roles can be created with specific permission combinations.
#------------------------------------------------------------------------------

resource "teamcity_role" "this" {
  for_each = var.custom_roles

  id   = upper(replace(each.key, "-", "_"))
  name = each.value.name

  # Permissions granted directly to this role
  permissions = each.value.permissions

  # Roles whose permissions are included in this role
  included = each.value.included_roles

  lifecycle {
    create_before_destroy = true
  }
}

#------------------------------------------------------------------------------
# Common TeamCity Permissions Reference
#------------------------------------------------------------------------------
# Build Permissions:
#   - RUN_BUILD: Start builds manually
#   - CANCEL_BUILD: Cancel running builds
#   - CANCEL_ANY_PERSONAL_BUILD: Cancel other users' personal builds
#   - PIN_UNPIN_BUILD: Pin/unpin builds
#   - TAG_BUILD: Add tags to builds
#   - PAUSE_ACTIVATE_BUILD_CONFIGURATION: Pause/activate configurations
#   - REMOVE_BUILD: Delete builds
#
# View Permissions:
#   - VIEW_PROJECT: View project
#   - VIEW_BUILD_CONFIGURATION_SETTINGS: View build configuration settings
#   - VIEW_FILE_CONTENT: View file content
#   - VIEW_BUILD_RUNTIME_DATA: View build parameters at runtime
#
# Edit Permissions:
#   - EDIT_PROJECT: Edit project settings
#   - CREATE_DELETE_VCS_ROOT: Manage VCS roots
#   - MANAGE_BUILD_PROBLEMS: Mute/unmute build problems
#   - MANAGE_BUILD_PROBLEM_INSTANCES: Manage specific problem instances
#
# Administration:
#   - ADMINISTER_AGENT: Administer build agents
#   - AUTHORIZE_AGENT: Authorize new agents
#   - ENABLE_DISABLE_AGENT: Enable/disable agents
#   - CHANGE_AGENT_RUN_POLICY: Change agent run policies
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Role Assignment to Groups
#------------------------------------------------------------------------------

resource "teamcity_group_role_assignment" "this" {
  for_each = {
    for item in flatten([
      for group_key, group in var.groups : [
        for role in group.roles : {
          key       = "${group_key}-${role}"
          group_key = group_key
          role_id   = role
        }
      ]
    ]) : item.key => item
  }

  group_key = each.value.group_key
  role_id   = each.value.role_id
  scope     = "g" # Global scope

  depends_on = [
    teamcity_group.this,
    teamcity_role.this
  ]
}

#------------------------------------------------------------------------------
# Role Assignment to Users (System-wide)
#------------------------------------------------------------------------------

resource "teamcity_user_role_assignment" "this" {
  for_each = {
    for item in flatten([
      for user_key, user in var.users : [
        for role in user.roles : {
          key      = "${user_key}-${role}"
          user_key = user_key
          role_id  = role
        }
      ]
    ]) : item.key => item
  }

  user_id = teamcity_user.this[each.value.user_key].id
  role_id = each.value.role_id
  scope   = "g" # Global scope

  depends_on = [
    teamcity_user.this,
    teamcity_role.this
  ]
}
