# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **VeeCode DevPortal Examples Repository** - a collection of Docker-based configuration samples demonstrating how to run VeeCode DevPortal (a Backstage-based developer portal) with different integrations and authentication providers.

This is **not a Node.js project** - it contains Docker Compose configurations and YAML files only. There is no build system, package.json, or test infrastructure.

## Common Commands

Start any example:

```bash
cd <example-directory>
docker compose up --no-log-prefix
```

Reload dynamic plugins without restart:

```bash
docker compose exec devportal /app/install-dynamic-plugins.sh /app/dynamic-plugins-root
```

Get authentication token for API testing:

```bash
USER_TOKEN="$(curl -s -X POST http://localhost:7007/api/auth/guest/refresh \
  -H 'Content-Type: application/json' -d '{}' | jq -r '.backstageIdentity.token')"
```

Test backend endpoints:

```bash
curl -H "Authorization: Bearer $USER_TOKEN" http://localhost:7007/api/catalog/entities
curl http://localhost:7007/healthcheck
curl http://localhost:7007/version
```

## Architecture

### Profile System

All examples use `VEECODE_PROFILE` environment variable to select bundled configurations:

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

### Example Structure

Each example directory follows a consistent pattern:

- `docker-compose.yml` - Service definition with environment variables
- `dynamic-plugins.yaml` - Enabled/disabled plugins configuration
- `app-config.yaml` - Application overrides (optional)
- `README.md` - Setup instructions (optional)

### Dynamic Plugins

Plugins are pre-installed in the Docker image at `dynamic-plugins-root`. The `dynamic-plugins.yaml` file controls which plugins are active and can include bundled defaults:

```yaml
includes:
  - dynamic-plugins.default.yaml
plugins:
  - package: ./dynamic-plugins-root/plugin-name
    disabled: false
```

### RBAC

Role-based access control uses Casbin format in `rbac-policy.csv` files. Roles include `admin`, `developer`, etc., with permissions for catalog, scaffolder, kubernetes operations.

## Key Environment Variables by Integration

| Integration | Variables |
|-------------|-----------|
| GitHub | `GITHUB_ORG`, `GITHUB_APP_ID`, `GITHUB_AUTH_CLIENT_ID`, `GITHUB_AUTH_CLIENT_SECRET`, `GITHUB_TOKEN`, `GITHUB_PRIVATE_KEY_BASE64` |
| Azure | `AZURE_TENANT_ID`, `AZURE_CLIENT_ID`, `AZURE_CLIENT_SECRET`, `AZURE_ORGANIZATION`, `AZURE_TOKEN` |
| LDAP | `LDAP_URL`, `LDAP_DN`, `LDAP_SECRET`, `LDAP_USERS_BASE_DN`, `LDAP_GROUPS_BASE_DN` |
| Jenkins | `JENKINS_URL`, `JENKINS_USERNAME`, `JENKINS_TOKEN` |
| SonarQube | `SONAR_TOKEN` |
| Bitbucket | `BITBUCKET_WORKSPACE`, `BITBUCKET_USERNAME`, `BITBUCKET_TOKEN`, `BITBUCKET_CLIENT_ID` |

## Documentation

- [Profiles Documentation](https://docs.platform.vee.codes/devportal/installation-guide/docker-local/profiles)
- [GitHub Integration](https://docs.platform.vee.codes/devportal/integrations/GitHub/)
- [Azure Integration](https://docs.platform.vee.codes/devportal/integrations/Azure/)
