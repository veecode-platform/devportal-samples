# GitHub Example

This example demonstrates how to run VeeCode DevPortal locally with GitHub integration enabled. It uses Docker Compose to start the DevPortal with GitHub-specific plugins and configurations.

The environment variable `VEECODE_PROFILE` is set to `github`, which configures the DevPortal to use GitHub as authentication and catalog provider. The `VEECODE_PROFILE` is a convenience feature that merges a bundled `app-config.yaml` into the runtime configuration.

## Overview

This setup provides a complete GitHub integration for the DevPortal, enabling features like:

- User authentication via GitHub OAuth
- Repository catalog, insights and metrics
- Security vulnerability scanning
- GitHub Actions workflow visualization and management
- GitHub scaffolding of projects from templates

## Prerequisites

- Docker Desktop or compatible container engine
- GitHub account and organization
- OAuth App configured for your organization (see below)
- GitHub App configured for your organization (see below)

## Required Environment Variables

Before running this example, you need to configure the following GitHub credentials as environment variables:

### GitHub Settings

This example uses the **GitHub profile** (`VEECODE_PROFILE=github`). The profile wires both:

- **Authentication** (how users sign in) via a GitHub OAuth App
- **Backend integrations** (catalog discovery, plugins, scaffolder actions, etc.) via a GitHub App and/or PAT

Required environment variables (as per the GitHub profile docs):

- `GITHUB_ORG` - Your GitHub organization name
- `GITHUB_APP_ID` - GitHub App ID
- `GITHUB_AUTH_CLIENT_ID` - OAuth App client ID (authentication)
- `GITHUB_AUTH_CLIENT_SECRET` - OAuth App client secret (authentication)
- `GITHUB_CLIENT_ID` - GitHub App client ID (integrations)
- `GITHUB_CLIENT_SECRET` - GitHub App client secret (integrations)
- `GITHUB_PRIVATE_KEY` **or** `GITHUB_PRIVATE_KEY_BASE64` - GitHub App private key (PEM) (integrations)
- `GITHUB_TOKEN` - Personal access token (PAT) or GitHub App token (fallback for integrations)

Optional environment variables:

- `GITHUB_HOST` - GitHub Enterprise hostname (defaults to `github.com`)
- `GITHUB_AUTH_CLIENT_*` - If absent, DevPortal will fall back to `GITHUB_CLIENT_*` for auth

Docs: https://docs.platform.vee.codes/devportal/installation-guide/docker-local/profiles#github-profile

## Setup

DevPortal integrates with GitHub for both authentication and backend integrations. The best arrangement is to create:

- An OAuth App for user authentication
- A GitHub App for backend integrations
- An optional GitHub PAT (Personal Access Token) for fallback integrations and legacy plugins.

We are also using the `github` profile provided by VeeCode DevPortal to simplify the configuration. You can read more about profiles, authentication and integrations in the documentation:

- [GitHub Auth & Integrations](https://docs.platform.vee.codes/devportal/integrations/GitHub/)
- [Quick Setup with Profiles](https://docs.platform.vee.codes/devportal/installation-guide/docker-local/profiles) (check the GitHub profile section)

### 1. Create an OAuth App (Authentication)

Create a GitHub **OAuth App** to enable sign-in.

- Follow the official guide: https://docs.platform.vee.codes/devportal/integrations/GitHub/github-auth
- Don't forget to set the callback URL to: `http://localhost:7007/api/auth/github/handler/frame`

### 2. Create a GitHub App (Backend integrations)

Create a GitHub **App** for backend access (catalog discovery and GitHub-powered plugins).

- Guide: https://docs.platform.vee.codes/devportal/integrations/GitHub/github-integrations

### 3. (Optional) Create a PAT (Fallback)

Some plugins and edge cases may still require a PAT (and it can be used as a fallback when the GitHub App is not installed for a repo).

- More context and the credential decision tree: https://docs.platform.vee.codes/devportal/integrations/GitHub/

### 4. Set Environment Variables

Export the required environment variables in your shell:

```bash
export GITHUB_ORG="your-org-name"
export GITHUB_APP_ID="123456"
export GITHUB_AUTH_CLIENT_ID="Iv1.oauth_client_id"
export GITHUB_AUTH_CLIENT_SECRET="your-oauth-client-secret"
export GITHUB_CLIENT_ID="Iv1.github_app_client_id"
export GITHUB_CLIENT_SECRET="your-github-app-client-secret"
export GITHUB_PRIVATE_KEY_BASE64="$(cat path/to/your-github-app-private-key.pem | base64)"
export GITHUB_TOKEN="ghp_your_personal_access_token"
```

## Running the Example

### Start DevPortal

```bash
docker compose up --no-log-prefix
```

The DevPortal will be available at: **<http://localhost:7007>**

If authentication fails, double-check your OAuth callback URL:

- `http://localhost:7007/api/auth/github/handler/frame`

Docs: https://docs.platform.vee.codes/devportal/installation-guide/docker-local/profiles#authentication-fails

### Apply Dynamic Plugin Changes

If you modify the `dynamic-plugins.yaml` file while the container is running, you can reload the plugins without restarting:

```bash
docker compose exec devportal /app/install-dynamic-plugins.sh /app/dynamic-plugins-root
```

## Enabled Plugins

This example enables the following GitHub-related dynamic plugins:

- **`roadiehq-backstage-plugin-security-insights`** - Displays security vulnerabilities and insights from GitHub
- **`roadiehq-backstage-plugin-github-insights`** - Shows GitHub repository statistics and information
- **`backstage-community-plugin-github-actions`** - Visualizes GitHub Actions workflows
- **`veecode-platform-backstage-plugin-github-workflows-backend`** - Backend for GitHub workflows management
- **`veecode-platform-backstage-plugin-github-workflows`** - Frontend for GitHub workflows management

## Configuration Files

### docker-compose.yml

Defines the DevPortal service with:

- Development mode enabled
- GitHub profile configuration
- Port mapping (7007)
- Environment variable injection
- Volume mount for dynamic plugins configuration

### dynamic-plugins.yaml

Configures which plugins are enabled/disabled. This file:

- Includes default plugin configurations from the base image
- Explicitly enables GitHub-related plugins
- Can be modified to enable/disable specific functionality

## Troubleshooting

### Missing Environment Variables

If you see authentication errors, ensure all required environment variables are set:

```bash
env | grep GITHUB
```

### Permission Issues

Ensure your GitHub App has the necessary permissions for the repositories and organization you're trying to access.

## Next Steps

Once the DevPortal is running:

1. Navigate to <http://localhost:7007>
2. Sign in using your GitHub credentials
3. Explore the catalog and GitHub-integrated features
4. Check if organization teams and members were loaded as users and groups
5. Check if repositories were loaded according to their `catalog-info.yaml` files


For deeper customization, you can keep `VEECODE_PROFILE=github` and override settings via `app-config.local.yaml`.

Docs:

- https://docs.platform.vee.codes/devportal/installation-guide/docker-local/profiles#combining-profiles-with-custom-config
- https://docs.platform.vee.codes/devportal/installation-guide/docker-local/custom-config
