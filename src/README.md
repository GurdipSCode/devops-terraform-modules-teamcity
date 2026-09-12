# TeamCity Terraform Module

A comprehensive Terraform module for managing [JetBrains TeamCity](https://www.jetbrains.com/teamcity/) CI/CD server infrastructure.

## Overview

This module uses the official [JetBrains TeamCity Terraform Provider](https://registry.terraform.io/providers/JetBrains/teamcity/latest) to automate TeamCity server administration including:

- Global server settings
- Authentication modules (built-in, OAuth)
- Users, groups, and permissions
- Custom roles
- Projects and VCS roots
- Connections (GitHub, GitLab, Bitbucket)
- Agent pools
- Cleanup rules

## Usage

### Basic Example

```hcl
module "teamcity" {
  source = "./terraform-teamcity-module"

  teamcity_host  = "http://localhost:8111"
  teamcity_token = var.teamcity_token

  # Create users
  users = {
    "admin" = {
      username = "admin"
      name     = "Administrator"
      email    = "admin@example.com"
      password = var.admin_password
      roles    = ["SYSTEM_ADMIN"]
    }
  }

  # Create a project
  projects = {
    "web-app" = {
      name        = "Web Application"
      description = "Main web application"
      vcs_roots = {
        "github" = {
          url         = "https://github.com/myorg/webapp.git"
          branch      = "refs/heads/main"
          auth_method = "anonymous"
        }
      }
    }
  }
}
```

### Complete Example

```hcl
module "teamcity" {
  source = "./terraform-teamcity-module"

  teamcity_host  = "https://teamcity.example.com"
  teamcity_token = var.teamcity_token

  # Server settings
  server_url                 = "https://teamcity.example.com"
  default_execution_timeout  = 60
  default_vcs_check_interval = 60

  # Authentication
  auth_modules = {
    "github-oauth" = {
      type                 = "github"
      client_id            = var.github_client_id
      client_secret        = var.github_client_secret
      allow_creating_users = true
    }
  }

  # SMTP for notifications
  smtp_config = {
    host     = "smtp.example.com"
    port     = 587
    from     = "teamcity@example.com"
    login    = "teamcity"
    password = var.smtp_password
    secure   = "starttls"
  }

  # Users
  users = {
    "admin" = {
      username = "admin"
      name     = "Platform Admin"
      email    = "admin@example.com"
      password = var.admin_password
      roles    = ["SYSTEM_ADMIN"]
    }
    "developer" = {
      username = "jsmith"
      name     = "John Smith"
      email    = "jsmith@example.com"
      password = var.developer_password
      roles    = ["PROJECT_DEVELOPER"]
    }
  }

  # Groups
  groups = {
    "developers" = {
      name        = "Developers"
      description = "Development team"
      roles       = ["PROJECT_DEVELOPER"]
    }
    "ops" = {
      name        = "Operations"
      description = "Operations team"
      roles       = ["PROJECT_ADMIN"]
    }
  }

  # Custom roles
  custom_roles = {
    "deploy-manager" = {
      name = "Deploy Manager"
      permissions = [
        "RUN_BUILD",
        "VIEW_PROJECT",
        "PIN_UNPIN_BUILD",
        "TAG_BUILD"
      ]
      included_roles = ["PROJECT_VIEWER"]
    }
  }

  # Projects
  projects = {
    "web-app" = {
      name        = "Web Application"
      description = "Customer-facing web application"
      parameters = {
        "env.ENVIRONMENT" = "production"
        "env.REGION"      = "us-east-1"
      }
      vcs_roots = {
        "main-repo" = {
          name        = "Main Repository"
          url         = "git@github.com:myorg/webapp.git"
          branch      = "refs/heads/main"
          auth_method = "ssh"
          private_key = var.deploy_ssh_key
        }
      }
    }
    "api-service" = {
      name        = "API Service"
      description = "Backend API service"
      vcs_roots = {
        "api-repo" = {
          name        = "API Repository"
          url         = "https://github.com/myorg/api.git"
          branch      = "refs/heads/main"
          auth_method = "password"
          username    = "oauth2"
          password    = var.github_token
        }
      }
    }
  }

  # Connections
  connections = {
    "github-app" = {
      type           = "github_app"
      display_name   = "GitHub App"
      app_id         = var.github_app_id
      client_id      = var.github_app_client_id
      client_secret  = var.github_app_client_secret
      private_key    = var.github_app_private_key
      webhook_secret = var.github_webhook_secret
      owner_url      = "https://github.com/myorg"
    }
  }

  # Agent pools
  agent_pools = {
    "linux" = {
      name        = "Linux Agents"
      max_agents  = 10
      project_ids = ["WebApplication", "ApiService"]
    }
    "windows" = {
      name        = "Windows Agents"
      max_agents  = 5
      project_ids = ["WebApplication"]
    }
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0.0 |
| teamcity | >= 0.0.50 |

## Providers

| Name | Version |
|------|---------|
| teamcity (jetbrains/teamcity) | >= 0.0.50 |

## Inputs

### Provider Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| teamcity_host | TeamCity server URL | `string` | n/a | yes |
| teamcity_token | Access token for authentication | `string` | `null` | no |
| max_retries | Max API request retries | `number` | `12` | no |

### Server Settings

| Name | Description | Type | Default |
|------|-------------|------|---------|
| server_url | Public server URL | `string` | `null` |
| max_artifact_size | Max artifact size (bytes) | `number` | `null` |
| default_execution_timeout | Build timeout (minutes) | `number` | `null` |
| default_vcs_check_interval | VCS polling interval (seconds) | `number` | `null` |

### Authentication

| Name | Description | Type | Default |
|------|-------------|------|---------|
| auth_modules | Authentication module configs | `map(object)` | `{}` |
| smtp_config | SMTP configuration | `object` | `null` |

### Users & Groups

| Name | Description | Type | Default |
|------|-------------|------|---------|
| users | User configurations | `map(object)` | `{}` |
| groups | Group configurations | `map(object)` | `{}` |
| custom_roles | Custom role definitions | `map(object)` | `{}` |

### Projects

| Name | Description | Type | Default |
|------|-------------|------|---------|
| projects | Project configurations with VCS roots | `map(object)` | `{}` |
| connections | External service connections | `map(object)` | `{}` |
| ssh_keys | SSH keys for VCS authentication | `map(object)` | `{}` |
| agent_pools | Agent pool configurations | `map(object)` | `{}` |

## Outputs

| Name | Description |
|------|-------------|
| user_ids | Map of user keys to IDs |
| group_ids | Map of group keys to IDs |
| project_ids | Map of project keys to IDs |
| project_urls | Web URLs for each project |
| vcs_root_ids | Map of VCS root keys to IDs |
| agent_pool_ids | Map of agent pool keys to IDs |
| admin_urls | Useful administration URLs |
| summary | Summary of all resources |

## Built-in Roles

| Role | Description |
|------|-------------|
| SYSTEM_ADMIN | Full server administration |
| PROJECT_ADMIN | Full project administration |
| PROJECT_DEVELOPER | Run builds, view configurations |
| PROJECT_VIEWER | View-only access |

## Common Permissions

```hcl
# Build permissions
"RUN_BUILD"
"CANCEL_BUILD"
"PIN_UNPIN_BUILD"
"TAG_BUILD"
"REMOVE_BUILD"

# View permissions
"VIEW_PROJECT"
"VIEW_BUILD_CONFIGURATION_SETTINGS"
"VIEW_FILE_CONTENT"

# Edit permissions
"EDIT_PROJECT"
"CREATE_DELETE_VCS_ROOT"
"MANAGE_BUILD_PROBLEMS"

# Agent permissions
"ADMINISTER_AGENT"
"AUTHORIZE_AGENT"
"ENABLE_DISABLE_AGENT"
```

## Terraform vs Kotlin DSL

TeamCity supports two configuration-as-code approaches:

| Feature | Terraform Provider | Kotlin DSL |
|---------|-------------------|------------|
| Server settings | ✅ Full support | ❌ Not available |
| User management | ✅ Full support | ❌ Not available |
| Roles & permissions | ✅ Full support | ❌ Not available |
| Cleanup rules | ✅ Full support | ❌ Not available |
| Project structure | ✅ Supported | ✅ Full support |
| Build configurations | ⚠️ Limited | ✅ Full support |
| Build steps | ❌ Not available | ✅ Full support |

**Recommendation**: Use Terraform for server administration and Kotlin DSL for build configurations.

## Getting Started

1. **Install TeamCity**
   ```bash
   docker run -d --name teamcity \
     -p 8111:8111 \
     jetbrains/teamcity-server
   ```

2. **Get an Access Token**
   - Log in to TeamCity
   - Go to Profile → Access Tokens
   - Create a token with admin permissions

3. **Configure the Module**
   ```hcl
   module "teamcity" {
     source         = "./terraform-teamcity-module"
     teamcity_host  = "http://localhost:8111"
     teamcity_token = var.teamcity_token
     # ... configuration
   }
   ```

4. **Apply**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## License

MIT License - see LICENSE file for details.

## Resources

- [TeamCity Documentation](https://www.jetbrains.com/help/teamcity/)
- [TeamCity Terraform Provider](https://registry.terraform.io/providers/JetBrains/teamcity/latest)
- [Provider GitHub Repository](https://github.com/JetBrains/terraform-provider-teamcity)
- [Kotlin DSL Documentation](https://www.jetbrains.com/help/teamcity/kotlin-dsl.html)
