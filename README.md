# devportal-samples

This repo contains several VeeCode DevPortal examples for local testing.

Each example tries to be self sufficient as possible, containing all the necessary files and configurations. External settings may be required, like API keys, tokens or certificates (like those required by Github).

## Prerequisites

Each example has its own prerequisites. Please check the README.md file of each example for more details.

## Examples

- [GitHub](github/README.md): starts DevPortal integrated with Github.

### Accessing Backend Endpoints

Backend API endpoints require authentication. The examples below show how to obtain and use a token (requires the relaxed security configuration above):

```sh
# get a Backstage user token via the guest provider
USER_TOKEN="$(curl -s -X POST http://localhost:7007/api/auth/guest/refresh \
  -H 'Content-Type: application/json' -d '{}' | jq -r '.backstageIdentity.token')"

# list loaded dynamic plugins
curl -H "Authorization: Bearer $USER_TOKEN" \
  http://localhost:7007/api/dynamic-plugins-info/loaded-plugins

# list catalog components
curl -H "Authorization: Bearer $USER_TOKEN" \
  http://localhost:7007/api/catalog/entities\?filter\=kind\=Component

# list all scaffolder actions
curl -H "Authorization: Bearer $USER_TOKEN" \
  http://localhost:7007/api/scaffolder/v2/actions

# healthcheck (no auth)
curl -vvv http://localhost:7007/healthcheck

# version (no auth)
curl -vvv http://localhost:7007/version

# send notification
# token defined by "backend.auth.externalAccess[0].options.token"
NOTIFY_TOKEN="test-token"
curl -X POST http://localhost:7007/api/notifications/notifications \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $NOTIFY_TOKEN" \
  -d '{
        "recipients": {
          "type": "broadcast"
        },
        "payload": {
          "title": "Title of broadcast message",
          "description": "The description of the message.",
          "link": "http://example.com/link",
          "severity": "high",
          "topic": "general"
        }
      }'
```
