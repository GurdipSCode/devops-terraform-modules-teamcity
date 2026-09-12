#------------------------------------------------------------------------------
# TeamCity Provider Configuration
#------------------------------------------------------------------------------
# The TeamCity provider connects to your TeamCity server's REST API.
#
# Authentication options:
# 1. Access Token (recommended):
#    - token: TeamCity access token with admin permissions
#    - Set via TEAMCITY_TOKEN environment variable
#
# 2. Password (for initial setup with super user token):
#    - password: Super user token or user password
#    - Set via TEAMCITY_PASSWORD environment variable
#
# Get access token from: TeamCity → Profile → Access Tokens
#------------------------------------------------------------------------------

provider "teamcity" {
  host        = var.teamcity_host
  token       = var.teamcity_token
  max_retries = var.max_retries
}
