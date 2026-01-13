# Bitbucket Server – Quickstart (VeeCode DevPortal)

This quickstart shows how to configure **Bitbucket Server** (self-hosted) integration in **VeeCode DevPortal** to:

- Import existing repositories into the Catalog
- Use Bitbucket actions in the Scaffolder

Note: there is no ready-to-use VEECODE_PROFILE for bitbucket, so we need to configure it manually.

---

## Prerequisites

- Docker Desktop (or compatible container engine)
- A self-hosted Bitbucket Server instance
- An HTTP access token with repository read permissions
- At least one repository with a valid `catalog-info.yaml` file

## Environment Variables

Required:

```bash
export BITBUCKET_SERVER_HOST=bitbucket.mycompany.com
export BITBUCKET_SERVER_API_URL=https://bitbucket.mycompany.com/rest/api/1.0
export BITBUCKET_SERVER_TOKEN=<your-http-access-token>
```

Alternative (username/password):

```bash
export BITBUCKET_SERVER_HOST=bitbucket.mycompany.com
export BITBUCKET_SERVER_API_URL=https://bitbucket.mycompany.com/rest/api/1.0
export BITBUCKET_SERVER_USERNAME=<your-username>
export BITBUCKET_SERVER_PASSWORD=<your-password>
```

---

## Configure DevPortal

Check `docker-compose.yml` for the environment variables:

```yaml
services:
  devportal:
    environment:
      - BITBUCKET_SERVER_HOST
      - BITBUCKET_SERVER_API_URL
      - BITBUCKET_SERVER_TOKEN
```

Check the Bitbucket Server dynamic plugins by editing `dynamic-plugins.yaml`:

```yaml
plugins:
  - package: ./dynamic-plugins/dist/backstage-plugin-catalog-backend-module-bitbucket-server-dynamic
    disabled: false

  - package: ./dynamic-plugins/dist/backstage-plugin-scaffolder-backend-module-bitbucket-server-dynamic
    disabled: false
```

These plugins enable:

- Automatic repository discovery (Catalog Provider)
- Bitbucket actions in the Scaffolder

## Bitbucket Server Integration

Configure the integration in `app-config.yaml`:

```yaml
integrations:
  bitbucketServer:
    - host: ${BITBUCKET_SERVER_HOST}
      apiBaseUrl: ${BITBUCKET_SERVER_API_URL}
      token: ${BITBUCKET_SERVER_TOKEN}
```

## Catalog Provider

```yaml
catalog:
  providers:
    bitbucketServer:
      bitbucketServerDemo: # identifies your ingested dataset
        host: ${BITBUCKET_SERVER_HOST}
        catalogPath: /catalog-info.yaml # default value
        # filters: # optional
        #   projectKey: '^apis-.*$' # optional; RegExp
        #   repoSlug: '^service-.*$' # optional; RegExp
        schedule:
          frequency: { minutes: 30 }
          timeout: { minutes: 3 }
```

This provider will periodically scan all repositories and import those containing a `catalog-info.yaml` file.

## Allow Reading from Bitbucket Server URLs

If you get errors from blocking requests to your Bitbucket Server, add the following to `app-config.yaml`:

```yaml
backend:
  reading:
    allow:
      - host: bitbucket.mycompany.com
```

---

## Start DevPortal

Start the DevPortal using Docker Compose:

```bash
docker compose up --no-log-prefix
```

The DevPortal will be available at:

```pre
http://localhost:7007
```

---

## Automatic Discovery

DevPortal should be able to use the [catalog provider](#catalog-provider) to automatically discover and import repositories containing a `catalog-info.yaml` file. Importing them individually is optional.

Locations can also be explicitly imported using `app-config.yaml`:

```yaml
locations:
  - type: url
    target: https://bitbucket.mycompany.com/projects/MYPROJECT/repos/my-repo/browse/catalog-info.yaml
```

## Import an Existing Repository into the Catalog

If you **really** need to import a repository manually:

1. Ensure the repository contains a `catalog-info.yaml` file
2. Open the DevPortal
3. Go to **Catalog > Register Existing Component**
4. Provide the full URL to the file

Format:

```pre
https://<bitbucket-host>/projects/<PROJECT>/repos/<repo>/raw/catalog-info.yaml?at=refs/heads/main
```

Example:

```pre
https://bitbucket.mycompany.com/projects/MYPROJECT/repos/my-api/raw/catalog-info.yaml?at=refs/heads/main
```

---

## Minimal catalog-info.yaml Example

If you have access to repos you may add similar files like this:

```yaml
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: my-api
  annotations:
    bitbucket.org/project-key: MYPROJECT
    bitbucket.org/repo-slug: my-api
spec:
  type: service
  lifecycle: experimental
  owner: group:default/admins
```

---

## Scaffolder – Available Actions

With the Bitbucket Server modules enabled, the following actions are available in the Scaffolder:

- `publish:bitbucketServer`
- `publish:bitbucketServer:pull-request`

---

## Troubleshooting

### Error: NotFoundError: Unable to read url

Check the following:

- The `catalog-info.yaml` file exists in the repository
- `integrations.bitbucketServer` is configured with host and apiBaseUrl
- `backend.reading.allow` includes your Bitbucket Server host
- The token has sufficient permissions

### Error: 401 Unauthorized

- Verify the HTTP access token is valid
- Ensure the token has repository read permissions
- Check if the token has expired

---

## Important Notes

- Bitbucket Server requires authentication for most operations
- HTTP access tokens are recommended over username/password
- The API base URL typically ends with `/rest/api/1.0`
- Project keys are uppercase (e.g., `MYPROJECT`)
