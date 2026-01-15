# devops-terraform-modules-teamcity

[![OpenTofu](https://img.shields.io/badge/OpenTofu-FFDA18?logo=opentofu&logoColor=black)](https://opentofu.org/)
[![TeamCity](https://img.shields.io/badge/TeamCity-000000?logo=teamcity&logoColor=white)](https://www.jetbrains.com/teamcity/)
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)
[![Release](https://img.shields.io/github/v/release/your-org/terraform-teamcity-module?color=green)](https://github.com/your-org/terraform-teamcity-module/releases)

[![Buildkite](https://img.shields.io/buildkite/your-buildkite-badge-id/main?logo=buildkite&label=build)](https://buildkite.com/your-org/terraform-teamcity-module)
[![CodeRabbit](https://img.shields.io/badge/CodeRabbit-Enabled-blue?logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAyNCAyNCI+PHBhdGggZmlsbD0iI2ZmZiIgZD0iTTEyIDRjLTQuNDIgMC04IDMuNTgtOCA4czMuNTggOCA4IDggOC0zLjU4IDgtOC0zLjU4LTgtOC04eiIvPjwvc3ZnPg==)](https://coderabbit.ai)
[![Security](https://img.shields.io/badge/Security-Trivy-1904DA?logo=aquasecurity&logoColor=white)](https://trivy.dev/)
[![Checkov](https://img.shields.io/badge/Checkov-Passing-4CAF50?logo=paloaltonetworks&logoColor=white)](https://www.checkov.io/)

---

OpenTofu module for managing [JetBrains TeamCity](https://www.jetbrains.com/teamcity/) resources including projects, build configurations, VCS roots, agents, and agent pools.

## ✨ Features

- 📁 Create and manage projects and subprojects
- 🔨 Configure build configurations and templates
- 🔗 Manage VCS roots (Git, GitHub, GitLab, Bitbucket)
- 🤖 Configure build agents and agent pools
- 🔐 Manage parameters, secrets, and credentials
- 🔔 Set up notifications and integrations
- 👥 Manage users, groups, and roles

## 📋 Requirements

| Name | Version |
|------|---------|
| ![OpenTofu](https://img.shields.io/badge/-OpenTofu-FFDA18?logo=opentofu&logoColor=black&style=flat-square) | `>= 1.6.0` |
| ![TeamCity](https://img.shields.io/badge/-TeamCity-000000?logo=teamcity&logoColor=white&style=flat-square) | `>= 0.1.0` |

## 🚀 Usage

### Basic Project

```hcl
module "teamcity" {
  source  = "your-org/teamcity/teamcity"
  version = "1.0.0"

  projects = {
    my_app = {
      name        = "My Application"
      description = "Main application project"
    }
  }
}
```

### Project with Build Configuration

```hcl
module "teamcity" {
  source  = "your-org/teamcity/teamcity"
  version = "1.0.0"

  projects = {
    my_app = {
      name        = "My Application"
      description = "Main application project"
    }
  }

  vcs_roots = {
    my_app_repo = {
      project_id = "my_app"
      name       = "GitHub Repository"
      type       = "git"
      url        = "git@github.com:your-org/my-app.git"
      branch     = "refs/heads/main"
      auth_method = "ssh_key"
    }
  }

  build_configs = {
    my_app_build = {
      project_id  = "my_app"
      name        = "Build & Test"
      description = "Build and test the application"
      vcs_root_id = "my_app_repo"

      steps = [
        {
          type    = "script"
          name    = "Build"
          script  = "npm ci && npm run build"
        },
        {
          type    = "script"
          name    = "Test"
          script  = "npm test"
        }
      ]

      triggers = [
        {
          type = "vcs"
          branch_filter = "+:*"
        }
      ]
    }
  }
}
```

### Complete Example

```hcl
module "teamcity" {
  source  = "your-org/teamcity/teamcity"
  version = "1.0.0"

  # 📁 Projects
  projects = {
    platform = {
      name        = "Platform"
      description = "Platform team projects"
    }
    platform_api = {
      name        = "API Services"
      description = "Backend API services"
      parent_id   = "platform"
    }
    platform_web = {
      name        = "Web Applications"
      description = "Frontend applications"
      parent_id   = "platform"
    }
  }

  # 🔗 VCS Roots
  vcs_roots = {
    api_repo = {
      project_id  = "platform_api"
      name        = "API Repository"
      type        = "git"
      url         = "git@github.com:your-org/api.git"
      branch      = "refs/heads/main"
      auth_method = "ssh_key"
      ssh_key     = var.deploy_ssh_key
    }
    web_repo = {
      project_id  = "platform_web"
      name        = "Web Repository"
      type        = "git"
      url         = "git@github.com:your-org/web.git"
      branch      = "refs/heads/main"
      auth_method = "ssh_key"
      ssh_key     = var.deploy_ssh_key
    }
  }

  # 🔨 Build Configurations
  build_configs = {
    api_build = {
      project_id  = "platform_api"
      name        = "Build API"
      description = "Build and test API service"
      vcs_root_id = "api_repo"

      steps = [
        {
          type   = "script"
          name   = "Build"
          script = "./gradlew build"
        },
        {
          type   = "script"
          name   = "Test"
          script = "./gradlew test"
        },
        {
          type   = "docker"
          name   = "Build Image"
          script = "docker build -t api:%build.number% ."
        }
      ]

      triggers = [
        {
          type          = "vcs"
          branch_filter = "+:*"
        },
        {
          type     = "schedule"
          cron     = "0 0 2 * * ?"
          timezone = "UTC"
        }
      ]

      failure_conditions = {
        fail_on_metric_change   = true
        fail_on_test_failure    = true
        fail_on_non_zero_exit   = true
      }

      artifact_paths = [
        "build/libs/*.jar"
        "build/reports/**/*"
      ]
    }

    api_deploy = {
      project_id   = "platform_api"
      name         = "Deploy API"
      description  = "Deploy API to production"
      vcs_root_id  = "api_repo"
      is_composite = false

      steps = [
        {
          type   = "script"
          name   = "Deploy"
          script = "./deploy.sh production"
        }
      ]

      dependencies = [
        {
          build_config_id = "api_build"
          type            = "snapshot"
        }
      ]

      parameters = {
        "env.DEPLOY_ENV" = "production"
      }
    }

    web_build = {
      project_id  = "platform_web"
      name        = "Build Web"
      description = "Build and test web application"
      vcs_root_id = "web_repo"

      steps = [
        {
          type   = "script"
          name   = "Install"
          script = "npm ci"
        },
        {
          type   = "script"
          name   = "Lint"
          script = "npm run lint"
        },
        {
          type   = "script"
          name   = "Test"
          script = "npm test -- --coverage"
        },
        {
          type   = "script"
          name   = "Build"
          script = "npm run build"
        }
      ]

      triggers = [
        {
          type          = "vcs"
          branch_filter = "+:*"
        }
      ]

      artifact_paths = [
        "dist/**/*"
        "coverage/**/*"
      ]
    }
  }

  # 🤖 Agent Pools
  agent_pools = {
    linux_pool = {
      name        = "Linux Agents"
      max_agents  = 10
    }
    windows_pool = {
      name        = "Windows Agents"
      max_agents  = 5
    }
    docker_pool = {
      name        = "Docker Agents"
      max_agents  = 8
    }
  }

  # 🔐 Project Parameters
  project_parameters = {
    platform = {
      "env.ARTIFACTORY_URL" = "https://artifactory.example.com"
      "env.DOCKER_REGISTRY" = "registry.example.com"
    }
  }

  # 🔔 Notifications
  notifications = {
    slack_builds = {
      project_id = "platform"
      type       = "slack"
      events     = ["build_failed", "build_successful"]
      webhook    = var.slack_webhook_url
      channel    = "#builds"
    }
  }

  tags = {
    Environment = "production"
    Team        = "platform"
    ManagedBy   = "opentofu"
  }
}
```

<!-- BEGIN_TF_DOCS -->
## 📥 Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `projects` | Map of TeamCity projects to create | `map(object({ name = string, description = string, parent_id = optional(string) }))` | `{}` | no |
| `vcs_roots` | Map of VCS roots to create | `map(object({ project_id = string, name = string, type = string, url = string, branch = string, auth_method = string, ssh_key = optional(string) }))` | `{}` | no |
| `build_configs` | Map of build configurations to create | `map(object({ project_id = string, name = string, description = string, vcs_root_id = string, steps = list(object({ type = string, name = string, script = string })), triggers = list(object({ type = string, branch_filter = optional(string) })) }))` | `{}` | no |
| `agent_pools` | Map of agent pools to create | `map(object({ name = string, max_agents = number }))` | `{}` | no |
| `project_parameters` | Map of project parameters | `map(map(string))` | `{}` | no |
| `notifications` | Map of notification configurations | `map(object({ project_id = string, type = string, events = list(string), webhook = string, channel = string }))` | `{}` | no |
| `tags` | Tags to apply to resources | `map(string)` | `{}` | no |

## 📤 Outputs

| Name | Description |
|------|-------------|
| `project_ids` | Map of project names to their IDs |
| `vcs_root_ids` | Map of VCS root names to their IDs |
| `build_config_ids` | Map of build config names to their IDs |
| `agent_pool_ids` | Map of agent pool names to their IDs |
| `webhook_urls` | Map of build configs to their webhook trigger URLs |
<!-- END_TF_DOCS -->

## ⚙️ Provider Configuration

Configure the TeamCity provider in your root module:

```hcl
terraform {
  required_providers {
    teamcity = {
      source  = "jetbrains/teamcity"
      version = "~> 0.1.0"
    }
  }
}

provider "teamcity" {
  host     = var.teamcity_host      # Or set TEAMCITY_HOST env var
  token    = var.teamcity_token     # Or set TEAMCITY_TOKEN env var
  # Or use username/password:
  # username = var.teamcity_username
  # password = var.teamcity_password
}
```

## 📂 Examples

| Example | Description |
|---------|-------------|
| [🟢 Basic](./examples/basic) | Simple project setup |
| [🔵 Complete](./examples/complete) | Full configuration with builds and agents |
| [🟣 Multi-Project](./examples/multi-project) | Hierarchical project structure |
| [🟠 Pipelines](./examples/pipelines) | Build chains and dependencies |

## 🔒 Security Considerations

> ⚠️ **Important Security Notes**

| Item | Recommendation |
|------|----------------|
| 🔑 API Tokens | Store in Vault or secure secrets manager |
| 🔐 SSH Keys | Use dedicated deploy keys with minimal permissions |
| 📋 Parameters | Mark sensitive values as `password` type |
| 👥 Roles | Follow least-privilege principle for user roles |
| 🌐 Network | Restrict agent communication to TeamCity server |

## 🔄 Migration Guide

### v0.x → v1.0

> ⚠️ **Breaking changes in v1.0**

| Change | Before (v0.x) | After (v1.0) |
|--------|---------------|--------------|
| Projects | `project` | `projects` (map) |
| Build configs | `build_configuration` | `build_configs` (map) |
| VCS roots | `vcs_root` | `vcs_roots` (map) |

```hcl
# ❌ Before (v0.x)
module "teamcity" {
  source       = "your-org/teamcity/teamcity"
  version      = "0.5.0"
  project_name = "MyProject"
}

# ✅ After (v1.0)
module "teamcity" {
  source  = "your-org/teamcity/teamcity"
  version = "1.0.0"
  projects = {
    my_project = {
      name        = "MyProject"
      description = "My project"
    }
  }
}
```

## 🤝 Contributing

1. 🍴 Fork the repository
2. 🌿 Create a feature branch (`git checkout -b feat/new-feature`)
3. 💾 Commit changes using [Conventional Commits](https://www.conventionalcommits.org/)
4. 📤 Push to the branch (`git push origin feat/new-feature`)
5. 🔃 Open a Pull Request

### 📝 Commit Message Format

```
<type>(<scope>): <description>
```

| Type | Description |
|------|-------------|
| `feat` | ✨ New feature |
| `fix` | 🐛 Bug fix |
| `docs` | 📚 Documentation |
| `refactor` | ♻️ Code refactoring |
| `test` | 🧪 Tests |
| `chore` | 🔧 Maintenance |

**Scopes:** `projects`, `builds`, `vcs`, `agents`, `notifications`, `examples`, `docs`

### 🛠️ Local Development

```bash
# 🎨 Format code
tofu fmt -recursive

# ✅ Validate
tofu validate

# 📖 Generate docs
terraform-docs markdown table . > README.md

# 🧪 Run tests
cd examples/basic && tofu init && tofu plan
```

## 📄 License

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)

Apache 2.0 - See [LICENSE](LICENSE) for details.

## 👥 Authors

Maintained by **Your Organization**.

## 🔗 Related

| Resource | Link |
|----------|------|
| 📖 TeamCity Documentation | [jetbrains.com/help/teamcity](https://www.jetbrains.com/help/teamcity/) |
| 🔌 TeamCity Provider | [Registry](https://registry.terraform.io/providers/jetbrains/teamcity/latest/docs) |
| 🔧 TeamCity REST API | [API Docs](https://www.jetbrains.com/help/teamcity/rest-api.html) |
| 📋 Kotlin DSL | [DSL Reference](https://www.jetbrains.com/help/teamcity/kotlin-dsl.html) |
| 🟡 OpenTofu | [opentofu.org](https://opentofu.org/) |
| 🟢 Buildkite | [buildkite.com](https://buildkite.com/) |

---

<p align="center">
  <sub>Built with ❤️ using <img src="https://img.shields.io/badge/-OpenTofu-FFDA18?logo=opentofu&logoColor=black&style=flat-square" alt="OpenTofu" /> and <img src="https://img.shields.io/badge/-Buildkite-14CC80?logo=buildkite&logoColor=white&style=flat-square" alt="Buildkite" /></sub>
</p>
