# Azure DevOps Example

This example demonstrates how to run VeeCode DevPortal locally with Azure DevOps integration enabled. It uses Docker Compose to start the DevPortal with Azure DevOps-specific plugins and configurations.

The environment variable `VEECODE_PROFILE` is set to `azure`, which configures the DevPortal to use Azure DevOps as authentication and catalog provider. The `VEECODE_PROFILE` is a convenience feature that merges a bundled `app-config.yaml` into the runtime configuration.

## Overview

This setup provides a complete Azure DevOps integration for the DevPortal, enabling features like:

- Repository insights and metrics
- Azure Pipelines visualization and management
- Pull request tracking and management
- Azure DevOps project and repository integration

## Prerequisites

- Docker Desktop or compatible container engine
- Azure DevOps organization and project
- Azure AD App registration configured (see Setup section)

## Required Environment Variables

Before running this example, you need to configure the following Azure credentials as environment variables:

### Azure Settings

- `AZURE_TENANT_ID` - Your Azure AD tenant ID
- `AZURE_CLIENT_ID` - The client ID from your Azure AD App registration
- `AZURE_CLIENT_SECRET` - The client secret for your Azure AD App
- `AZURE_ORGANIZATION` - Your Azure DevOps organization name
- `AZURE_PROJECT` - Your Azure DevOps project name
- `AZURE_TOKEN` - A personal access token with appropriate permissions

## Setup

### 1. Create an Azure AD App Registration

You can create both an Azure AD App registration and a Personal Access Token by following the instructions in the following links:

- [Quick Setup with Profiles](https://docs.platform.vee.codes/devportal/installation-guide/docker-local/profiles)
- [Azure DevOps Integrations](https://docs.platform.vee.codes/devportal/integrations/Azure/)

### 2. Set Environment Variables

Export the required environment variables in your shell:

```bash
export AZURE_TENANT_ID="your-tenant-id"
export AZURE_CLIENT_ID="your-client-id"
export AZURE_CLIENT_SECRET="your-client-secret"
export AZURE_ORGANIZATION="your-org-name"
export AZURE_PROJECT="your-project-name"
export AZURE_TOKEN="your-personal-access-token"
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

This example enables the following Azure DevOps-related dynamic plugins:

- **`backstage-community-plugin-azure-devops`** - Provides Azure DevOps integration for repositories, pull requests, and pipelines
- **`backstage-community-plugin-azure-devops-backend`** - Backend services for Azure DevOps integration

## Configuration Files

### docker-compose.yml

Defines the DevPortal service with:

- Development mode enabled
- Azure profile configuration
- Port mapping (7007)
- Environment variable injection
- Volume mount for dynamic plugins configuration

### dynamic-plugins.yaml

Configures which plugins are enabled/disabled. This file:

- Includes default plugin configurations from the base image
- Explicitly enables Azure DevOps-related plugins
- Can be modified to enable/disable specific functionality

## Troubleshooting

### Missing Environment Variables

If you see authentication errors, ensure all required environment variables are set:

```bash
env | grep AZURE
```

### Permission Issues

Ensure your Azure AD App has the necessary permissions for the organization and projects you're trying to access. Also verify that your Personal Access Token has the required scopes.

## Next Steps

Once the DevPortal is running:

1. Navigate to <http://localhost:7007>
2. Sign in using your Azure AD credentials
3. Explore the catalog and Azure DevOps-integrated features
4. Check if organization teams and members were loaded as users and groups
5. Check if repositories were loaded according to their `catalog-info.yaml` files
