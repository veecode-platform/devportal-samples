# Azure DevOps Example

This example demonstrates how to run VeeCode DevPortal locally with Azure DevOps integration enabled. It uses Docker Compose to start the DevPortal with Azure DevOps-specific plugins and configurations.

The environment variable `VEECODE_PRESETS` is set to `recommended,veecode-theme,azure,azure-auth`, which composes the DevPortal from self-contained presets. The `azure` preset wires Azure DevOps as the catalog/SCM provider (integration + catalog discovery + Pipelines/PR tabs) and `azure-auth` adds Microsoft (Entra ID) OAuth sign-in plus msgraphOrg user sync. Each preset merges its own plugins and `app-config` into the runtime configuration at boot.

## Overview

This setup provides a complete Azure DevOps integration for the DevPortal, enabling features like:

- User authentication via Microsoft / Entra ID OAuth (`azure-auth` preset)
- Repository insights and metrics (`azure` preset)
- Azure Pipelines visualization and management
- Pull request tracking and management
- Azure DevOps project and repository integration

## Prerequisites

- Docker Desktop or compatible container engine
- Azure DevOps organization and project
- An Entra ID (Azure AD) App registration for sign-in (see below)
- An Azure DevOps Personal Access Token (PAT) for backend integrations

## Required Environment Variables

Before running this example, you need to configure the following Azure credentials as environment variables:

### Azure Settings

This example composes two presets:

- **`azure`** — Azure DevOps as catalog/SCM: backend integration via a PAT, repository discovery, and the Pipelines / Pull Request tabs.
- **`azure-auth`** — Microsoft as identity: Entra ID OAuth sign-in plus msgraphOrg user and group sync.

Required environment variables (as passed through by `docker-compose.yml`):

- `AZURE_DEVOPS_TOKEN` - Azure DevOps Personal Access Token used for backend integrations and repository discovery (replaces the V1 `AZURE_TOKEN`)
- `AZURE_DEVOPS_HOST` - Azure DevOps host, defaults to `dev.azure.com` in `docker-compose.yml`
- `AZURE_DEVOPS_ORG` - Your Azure DevOps organization name (replaces the V1 `AZURE_ORGANIZATION`)
- `AZURE_DEVOPS_PROJECT` - Your Azure DevOps project name (replaces the V1 `AZURE_PROJECT`)
- `AZURE_AUTH_TENANT_ID` - Entra ID (Azure AD) tenant ID (replaces the V1 `AZURE_TENANT_ID`)
- `AZURE_AUTH_CLIENT_ID` - App registration client ID, authentication (replaces the V1 `AZURE_CLIENT_ID`)
- `AZURE_AUTH_CLIENT_SECRET` - App registration client secret, authentication (replaces the V1 `AZURE_CLIENT_SECRET`)

Docs: https://docs.platform.vee.codes/devportal/integrations/Azure/

## Setup

DevPortal integrates with Azure for both authentication (`azure-auth`) and backend integrations (`azure`). For this example you create:

- An Entra ID (Azure AD) App registration for user authentication
- An Azure DevOps PAT (Personal Access Token) for backend integrations and repository discovery

You can read more about the Azure presets, authentication and integrations in the documentation:

- [Azure DevOps Integrations](https://docs.platform.vee.codes/devportal/integrations/Azure/)
- [Presets (VEECODE_PRESETS)](https://docs.platform.vee.codes/devportal/installation-guide/docker-local/presets) (check the Azure presets section)

### 1. Create an Entra ID App Registration (Authentication)

Create an Entra ID (Azure AD) App registration to enable Microsoft sign-in.

- Follow the official guide: https://docs.platform.vee.codes/devportal/integrations/Azure/
- Don't forget to set the callback URL to: `http://localhost:7007/api/auth/microsoft/handler/frame`

### 2. Create a PAT (Backend integrations)

Create an Azure DevOps **Personal Access Token** for backend access (catalog discovery and Azure DevOps-powered plugins).

- More context: https://docs.platform.vee.codes/devportal/integrations/Azure/

### 3. Set Environment Variables

Export the required environment variables in your shell:

```bash
export AZURE_DEVOPS_TOKEN="your-personal-access-token"
export AZURE_DEVOPS_ORG="your-org-name"
export AZURE_DEVOPS_PROJECT="your-project-name"
export AZURE_AUTH_TENANT_ID="your-tenant-id"
export AZURE_AUTH_CLIENT_ID="your-client-id"
export AZURE_AUTH_CLIENT_SECRET="your-client-secret"
```

`AZURE_DEVOPS_HOST` defaults to `dev.azure.com` in `docker-compose.yml`; override it only for Azure DevOps Server.

## Running the Example

### Start DevPortal

```bash
docker compose up --no-log-prefix
```

The DevPortal will be available at: **<http://localhost:7007>**

If authentication fails, double-check your OAuth callback URL:

- `http://localhost:7007/api/auth/microsoft/handler/frame`

### Apply Dynamic Plugin Changes

If you modify the `dynamic-plugins.yaml` file while the container is running, you can reload the plugins without restarting:

```bash
docker compose exec devportal /app/install-dynamic-plugins.sh /app/dynamic-plugins-root
```

## Enabled Plugins

The Azure DevOps-related dynamic plugins are enabled by the `azure` and `azure-auth` presets — you do not list them in `dynamic-plugins.yaml`. The presets contribute, among others:

- **`backstage-community-plugin-azure-devops`** - Provides Azure DevOps integration for repositories, pull requests, and pipelines
- **`backstage-community-plugin-azure-devops-backend`** - Backend services for Azure DevOps integration

To enable additional optional plugins (or disable a core one), edit `dynamic-plugins.yaml`.

## Configuration Files

### docker-compose.yml

Defines the DevPortal service with:

- Development mode enabled
- Azure presets configuration (`VEECODE_PRESETS=recommended,veecode-theme,azure,azure-auth`)
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
env | grep AZURE
```

### Permission Issues

Ensure your Entra ID App registration has the necessary permissions for sign-in, and that your Azure DevOps Personal Access Token has the required scopes for the organization and projects you're trying to access.

## Next Steps

Once the DevPortal is running:

1. Navigate to <http://localhost:7007>
2. Sign in using your Microsoft / Entra ID credentials
3. Explore the catalog and Azure DevOps-integrated features
4. Check if organization teams and members were loaded as users and groups
5. Check if repositories were loaded according to their `catalog-info.yaml` files

For deeper customization, you can keep the same `VEECODE_PRESETS` and override settings via a mounted `app-config.local.yaml`.

Docs:

- https://docs.platform.vee.codes/devportal/installation-guide/docker-local/presets
- https://docs.platform.vee.codes/devportal/installation-guide/docker-local/custom-config
