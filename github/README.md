# GitHub Example

This example demonstrates how to run VeeCode DevPortal locally with GitHub integration enabled. It uses Docker Compose to start the DevPortal with GitHub-specific plugins and configurations.

The environment variable `VEECODE_PRESETS` is set to `recommended,veecode-theme,github,github-auth`, which composes the DevPortal from self-contained presets. The `github` preset wires GitHub as the catalog/SCM provider (PAT + repo discovery + GitHub Actions tab) and `github-auth` adds GitHub OAuth sign-in plus org/team user sync. Each preset merges its own plugins and `app-config` into the runtime configuration at boot.

## Overview

This setup provides a complete GitHub integration for the DevPortal, enabling features like:

- User authentication via GitHub OAuth (`github-auth` preset)
- Repository catalog discovery, insights and metrics (`github` preset)
- Security vulnerability scanning
- GitHub Actions workflow visualization and management
- GitHub scaffolding of projects from templates

## Prerequisites

- Docker Desktop or compatible container engine
- GitHub account and organization
- OAuth App configured for your organization (see below)
- A GitHub Personal Access Token (PAT) for backend integrations

## Required Environment Variables

Before running this example, you need to configure the following GitHub credentials as environment variables:

### GitHub Settings

This example composes two presets:

- **`github`** — GitHub as catalog/SCM: backend integration via a PAT, repository discovery, and the GitHub Actions tab.
- **`github-auth`** — GitHub as identity: OAuth sign-in plus GitHub org/team user and group sync.

Required environment variables (as passed through by `docker-compose.yml`):

- `GITHUB_PAT` - GitHub Personal Access Token used for backend integrations and repository discovery (replaces the V1 `GITHUB_TOKEN`)
- `GITHUB_ORG` - Your GitHub organization name
- `GITHUB_AUTH_CLIENT_ID` - OAuth App client ID (authentication)
- `GITHUB_AUTH_CLIENT_SECRET` - OAuth App client secret (authentication)

> **GitHub App users:** GitHub App integration (`GITHUB_APP_ID` / `GITHUB_CLIENT_ID` / `GITHUB_PRIVATE_KEY_BASE64`) is **not** covered by the `github` / `github-auth` presets. If you previously used a GitHub App, lift that `integrations.github[].apps` block into a mounted `app-config.local.yaml` (see `UPGRADING_FROM_BASE_DISTRO.md`).

Docs: https://docs.platform.vee.codes/devportal/integrations/GitHub/

## Setup

DevPortal integrates with GitHub for both authentication (`github-auth`) and backend integrations (`github`). For this example you create:

- An OAuth App for user authentication
- A GitHub PAT (Personal Access Token) for backend integrations and repository discovery

You can read more about the GitHub presets, authentication and integrations in the documentation:

- [GitHub Auth & Integrations](https://docs.platform.vee.codes/devportal/integrations/GitHub/)
- [Presets (VEECODE_PRESETS)](https://docs.platform.vee.codes/devportal/installation-guide/docker-local/presets) (check the GitHub presets section)

### 1. Create an OAuth App (Authentication)

Create a GitHub **OAuth App** to enable sign-in.

- Follow the official guide: https://docs.platform.vee.codes/devportal/integrations/GitHub/github-auth
- Don't forget to set the callback URL to: `http://localhost:7007/api/auth/github/handler/frame`

### 2. Create a PAT (Backend integrations)

Create a GitHub **Personal Access Token** for backend access (catalog discovery and GitHub-powered plugins).

- More context and the credential decision tree: https://docs.platform.vee.codes/devportal/integrations/GitHub/

### 3. Set Environment Variables

Export the required environment variables in your shell:

```bash
export GITHUB_PAT="ghp_your_personal_access_token"
export GITHUB_ORG="your-org-name"
export GITHUB_AUTH_CLIENT_ID="Iv1.oauth_client_id"
export GITHUB_AUTH_CLIENT_SECRET="your-oauth-client-secret"
```

## Running the Example

### Start DevPortal

```bash
docker compose up --no-log-prefix
```

The DevPortal will be available at: **<http://localhost:7007>**

If authentication fails, double-check your OAuth callback URL:

- `http://localhost:7007/api/auth/github/handler/frame`

### Apply Dynamic Plugin Changes

If you modify the `dynamic-plugins.yaml` file while the container is running, you can reload the plugins without restarting:

```bash
docker compose exec devportal /app/install-dynamic-plugins.sh /app/dynamic-plugins-root
```

## Enabled Plugins

The GitHub-related dynamic plugins (security insights, repository insights, GitHub Actions, and GitHub workflows) are enabled by the `github` and `github-auth` presets — you do not list them in `dynamic-plugins.yaml`. The presets contribute, among others:

- **`roadiehq-backstage-plugin-security-insights`** - Displays security vulnerabilities and insights from GitHub
- **`roadiehq-backstage-plugin-github-insights`** - Shows GitHub repository statistics and information
- **`backstage-community-plugin-github-actions`** - Visualizes GitHub Actions workflows
- **`veecode-platform-backstage-plugin-github-workflows-backend`** - Backend for GitHub workflows management
- **`veecode-platform-backstage-plugin-github-workflows`** - Frontend for GitHub workflows management

To enable additional optional plugins (or disable a core one), edit `dynamic-plugins.yaml`.

## Configuration Files

### docker-compose.yml

Defines the DevPortal service with:

- Development mode enabled
- GitHub presets configuration (`VEECODE_PRESETS=recommended,veecode-theme,github,github-auth`)
- Port mapping (7007)
- Environment variable injection
- Volume mount for the dynamic plugins boot file

### dynamic-plugins.yaml

The operator plugin boot file bind-mounted at `/app/dynamic-plugins.yaml`. This file:

- Carries the Core (always-on) plugins
- Is where you enable extra plugins or disable a core one
- Does **not** list preset plugins — those are added on top by the presets in `VEECODE_PRESETS`

## Troubleshooting

### Missing Environment Variables

If you see authentication errors, ensure all required environment variables are set:

```bash
env | grep GITHUB
```

### Permission Issues

Ensure your GitHub PAT and OAuth App have the necessary permissions for the repositories and organization you're trying to access.

## Next Steps

Once the DevPortal is running:

1. Navigate to <http://localhost:7007>
2. Sign in using your GitHub credentials
3. Explore the catalog and GitHub-integrated features
4. Check if organization teams and members were loaded as users and groups
5. Check if repositories were loaded according to their `catalog-info.yaml` files

For deeper customization, you can keep the same `VEECODE_PRESETS` and override settings via a mounted `app-config.local.yaml`.

Docs:

- https://docs.platform.vee.codes/devportal/installation-guide/docker-local/presets
- https://docs.platform.vee.codes/devportal/installation-guide/docker-local/custom-config
