# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **configuration-only repository** containing Docker Compose samples for VeeCode DevPortal (a Backstage-based developer portal). There is no build system, package.json, or test infrastructure - only YAML configuration files.

See [README.md](README.md) for available examples and common commands.

## Architecture

### Profile System

All examples use the `VEECODE_PROFILE` environment variable to select bundled configurations:

- `github` - GitHub OAuth + integrations
- `azure` - Azure DevOps authentication
- `ldap` - LDAP directory sync
- `local` - Local-only configuration
- `sonarqube` - SonarQube integration
- `bitbucket` - Bitbucket integration

### Configuration Merging Order

1. Base image `app-config.yaml`
2. Profile-specific overrides via `VEECODE_PROFILE`
3. `dynamic-plugins.yaml` plugin configurations
4. Optional `app-config.local.yaml` for final customization
5. Environment variable interpolation at runtime

### Example Directory Pattern

Each example follows this structure:

- `docker-compose.yml` - Service definition with environment variables
- `dynamic-plugins.yaml` - Plugin enable/disable configuration
- `app-config.yaml` - Application overrides (optional)

### Dynamic Plugins

Plugins are pre-installed in the Docker image at `dynamic-plugins-root`. The `dynamic-plugins.yaml` controls activation:

```yaml
includes:
  - dynamic-plugins.default.yaml
plugins:
  - package: ./dynamic-plugins-root/plugin-name
    disabled: false
```

### RBAC

Role-based access control uses Casbin format in `rbac-policy.csv` files with roles like `admin` and `developer`.

## Key Environment Variables

| Integration | Variables |
|-------------|-----------|
| GitHub | `GITHUB_ORG`, `GITHUB_APP_ID`, `GITHUB_AUTH_CLIENT_ID`, `GITHUB_AUTH_CLIENT_SECRET`, `GITHUB_TOKEN`, `GITHUB_PRIVATE_KEY_BASE64` |
| Azure | `AZURE_TENANT_ID`, `AZURE_CLIENT_ID`, `AZURE_CLIENT_SECRET`, `AZURE_ORGANIZATION`, `AZURE_TOKEN` |
| LDAP | `LDAP_URL`, `LDAP_DN`, `LDAP_SECRET`, `LDAP_USERS_BASE_DN`, `LDAP_GROUPS_BASE_DN` |
| Jenkins | `JENKINS_URL`, `JENKINS_USERNAME`, `JENKINS_TOKEN` |
| SonarQube | `SONAR_TOKEN` |
| Bitbucket Cloud | `BITBUCKET_WORKSPACE`, `BITBUCKET_USERNAME`, `BITBUCKET_PASSWORD`, `BITBUCKET_TOKEN`, `BITBUCKET_CLIENT_ID`, `BITBUCKET_CLIENT_SECRET` |
| Bitbucket Server | `BITBUCKET_SERVER_HOST`, `BITBUCKET_SERVER_API_URL`, `BITBUCKET_SERVER_TOKEN`, `BITBUCKET_SERVER_USERNAME`, `BITBUCKET_SERVER_PASSWORD` |
