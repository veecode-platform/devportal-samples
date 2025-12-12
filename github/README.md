# GitHub Example

This example demonstrates how to run VeeCode DevPortal locally with GitHub integration enabled. It uses Docker Compose to start the DevPortal with GitHub-specific plugins and configurations.

The environment variable `VEECODE_PROFILE` is set to `github`, which configures the DevPortal to use GitHub as authentication and catalog provider. The `VEECODE_PROFILE` is a convenience feature that merges a bundled `app-config.yaml` into the runtime configuration.

## Overview

This setup provides a complete GitHub integration for the DevPortal, enabling features like:

- Repository insights and metrics
- Security vulnerability scanning
- GitHub Actions workflow visualization and management
- GitHub application integration

## Prerequisites

- Docker Desktop or compatible container engine
- GitHub account and organization
- GitHub App configured for your organization (see Setup section)

## Required Environment Variables

Before running this example, you need to configure the following GitHub credentials as environment variables:

### GitHub Settings

- `GITHUB_ORG` - Your GitHub organization name
- `GITHUB_APP_ID` - The App ID from your GitHub App
- `GITHUB_CLIENT_ID` - OAuth Client ID
- `GITHUB_CLIENT_SECRET` - OAuth Client Secret
- `GITHUB_PRIVATE_KEY` - The private key for your GitHub App (PEM format)
- `GITHUB_TOKEN` - A personal access token with appropriate permissions

## Setup

### 1. Create a GitHub App

You can create both a GitHub App and a Personal Access Token by following the instructions in the following links:

- [Quick Setup with Profiles](https://docs.platform.vee.codes/devportal/installation-guide/docker-local/profiles)
- [GitHub Integrations](https://docs.platform.vee.codes/devportal/integrations/GitHub/)

### 2. Set Environment Variables

Export the required environment variables in your shell:

```bash
export GITHUB_ORG="your-org-name"
export GITHUB_APP_ID="123456"
export GITHUB_CLIENT_ID="Iv1.abc123def456"
export GITHUB_CLIENT_SECRET="your-client-secret"
export GITHUB_PRIVATE_KEY="$(cat path/to/your-private-key.pem)"
export GITHUB_TOKEN="ghp_your_personal_access_token"
```

## Running the Example

### Start DevPortal

```bash
docker compose up --no-log-prefix
```

The DevPortal will be available at: **<http://localhost:7007>**

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
5. Check if repositories were loaded accordinf to their `catalog-info.yaml` files
