# VeeCode DevPortal Samples

This repository contains Docker-based configuration samples for running [VeeCode DevPortal](https://docs.platform.vee.codes/devportal/) (a Backstage-based developer portal) with different integrations and authentication providers.

Each example is self-contained with all necessary configuration files. External settings like API keys, tokens, or certificates may be required depending on the integration.

## Prerequisites

- Docker and Docker Compose
- External service accounts and credentials (GitHub, Azure, Bitbucket, etc.) as needed

## Example Structure

Each example typically contains:

- `docker-compose.yml` - Starts DevPortal with required environment variables
- `dynamic-plugins.yaml` - Enables/disables dynamic plugins for the example
- `app-config.yaml` - DevPortal configuration overrides (optional)
- `README.md` - Setup instructions and prerequisites (optional)

## Available Examples

| Example | Description |
|---------|-------------|
| [appstarter](appstarter/) | Minimal starter configuration |
| [github](github/) | GitHub OAuth authentication and integrations |
| [azure](azure/) | Azure DevOps authentication and integrations |
| [bitbucket](bitbucket/) | Bitbucket Cloud/Server integration |
| [ldap](ldap/) | LDAP authentication and organization sync |
| [jenkins](jenkins/) | Jenkins CI/CD integration |
| [sonarqube](sonarqube/) | SonarQube code quality integration |
| [local-cluster](local-cluster/) | Local Kubernetes cluster integration |
| [remote-cluster](remote-cluster/) | Remote Kubernetes cluster integration |
| [bancorocks](bancorocks/) | Sample organization catalog |

Check each example's README for specific setup instructions.

## Running an Example

```bash
cd <example-directory>
docker compose up --no-log-prefix
```

DevPortal will be available at `http://localhost:7007`.

## Reloading Dynamic Plugins

Reload plugins without restarting the container:

```bash
docker compose exec devportal /app/install-dynamic-plugins.sh /app/dynamic-plugins-root
```

## Accessing Backend API Endpoints

Backend API endpoints require authentication. Obtain a token and test endpoints:

```bash
# Get a Backstage user token via the guest provider
USER_TOKEN="$(curl -s -X POST http://localhost:7007/api/auth/guest/refresh \
  -H 'Content-Type: application/json' -d '{}' | jq -r '.backstageIdentity.token')"

# List loaded dynamic plugins
curl -H "Authorization: Bearer $USER_TOKEN" \
  http://localhost:7007/api/dynamic-plugins-info/loaded-plugins

# List catalog components
curl -H "Authorization: Bearer $USER_TOKEN" \
  http://localhost:7007/api/catalog/entities\?filter\=kind\=Component

# List all scaffolder actions
curl -H "Authorization: Bearer $USER_TOKEN" \
  http://localhost:7007/api/scaffolder/v2/actions

# Healthcheck (no auth required)
curl http://localhost:7007/healthcheck

# Version (no auth required)
curl http://localhost:7007/version
```

### Sending Notifications

```bash
# Token defined by backend.auth.externalAccess[0].options.token
NOTIFY_TOKEN="test-token"
curl -X POST http://localhost:7007/api/notifications/notifications \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $NOTIFY_TOKEN" \
  -d '{
        "recipients": { "type": "broadcast" },
        "payload": {
          "title": "Title of broadcast message",
          "description": "The description of the message.",
          "link": "http://example.com/link",
          "severity": "high",
          "topic": "general"
        }
      }'
```

## Documentation

- [DevPortal Installation Guide](https://docs.platform.vee.codes/devportal/installation-guide/docker-local/)
- [Profiles Documentation](https://docs.platform.vee.codes/devportal/installation-guide/docker-local/profiles)
- [GitHub Integration](https://docs.platform.vee.codes/devportal/integrations/GitHub/)
- [Azure Integration](https://docs.platform.vee.codes/devportal/integrations/Azure/)
