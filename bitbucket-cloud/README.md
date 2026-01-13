# Bitbucket Cloud – Quickstart (VeeCode DevPortal)

This quickstart shows how to configure **Bitbucket Cloud** integration in **VeeCode DevPortal** to:

- Import existing repositories into the Catalog
- Use Bitbucket actions in the Scaffolder

Note: there is no ready-to-use VEECODE_PROFILE for bitbucket, so we need to configure it manually.

---

## Prerequisites

- Docker Desktop (or compatible container engine)
- A public Bitbucket Cloud workspace
- At least one public repository in the above workspace
- A valid `catalog-info.yaml` file in the above repository

## Environment Variables

Required:

```bash
export BITBUCKET_WORKSPACE=<your-bitbucket-workspace>
```

---

## Configure DevPortal

Check `docker-compose.yml` for the environment variables:

```yaml
services:
  devportal:
    environment:
      - BITBUCKET_WORKSPACE
```

Check the Bitbucket Cloud dynamic plugins by editing `dynamic-plugins.yaml`:

```yaml
plugins:
  - package: ./dynamic-plugins/dist/backstage-plugin-catalog-backend-module-bitbucket-cloud-dynamic
    disabled: false

  - package: ./dynamic-plugins/dist/backstage-plugin-scaffolder-backend-module-bitbucket-cloud-dynamic
    disabled: false
```

These plugins enable:

- Automatic repository discovery (Catalog Provider)
- Bitbucket actions in the Scaffolder

## Bitbucket Cloud Integration

We can ignore this section, as it is not required for Bitbucket Cloud integration when reading only public repositories.

```yaml
integrations:
  # nothing
```

## Catalog Provider

```yaml
catalog:
  providers:
    bitbucketCloud:
      bitbucketCloudDemo: # identifies your ingested dataset
        catalogPath: /catalog-info.yaml # default value
        # filters: # optional
        #   projectKey: '^apis-.*$' # optional; RegExp
        #   repoSlug: '^service-.*$' # optional; RegExp
        schedule: # same options as in SchedulerServiceTaskScheduleDefinition
          # supports cron, ISO duration, "human duration" as used in code
          frequency: { minutes: 30 }
          # supports ISO duration, "human duration" as used in code
          timeout: { minutes: 3 }
        workspace: ${BITBUCKET_WORKSPACE}
```

This provider will periodically scan all repositories in the workspace and import those containing a `catalog-info.yaml` file.

## Allow Reading from Bitbucket URLs

If you get errors from blocking requests to Bitbucket, you can add the following to `app-config.yaml`:

```yaml
backend:
  reading:
    allow:
      - host: bitbucket.org
      - host: api.bitbucket.org
      - host: www.bitbucket.org
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

Locations can also be explictly imported using `app-config.yaml`:

```yaml
locations:
  - type: url
    target: https://bitbucket.org/veecode-testes/rodrigo/src/main/catalog-info.yaml
```

## Import an Existing Repository into the Catalog

If you **really** need to import a repository manually:

1. Ensure the repository contains a `catalog-info.yaml` file
2. Open the DevPortal
3. Go to **Catalog → Register Existing Component**
4. Provide the full URL to the file using the `raw` endpoint

Format:

```
https://bitbucket.org/<workspace>/<repo>/raw/main/catalog-info.yaml
```

Example:

```
https://bitbucket.org/my-workspace/my-api/raw/main/catalog-info.yaml
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
    bitbucket.org/repo-slug: my-workspace/my-api
spec:
  type: service
  lifecycle: experimental
  owner: group:default/admins
```

---

## Scaffolder – Available Actions

With the Bitbucket modules enabled, the following actions are available in the Scaffolder:

- `publish:bitbucketCloud`
- `publish:bitbucketCloud:pull-request`
- `bitbucket:pipelines:run`

---

## Troubleshooting

### Error: NotFoundError: Unable to read url

Check the following:

- The `catalog-info.yaml` file exists in the repository
- The URL uses `/raw/` and not `/src/`
- `integrations.bitbucket` is configured
- `backend.reading.allow` includes Bitbucket hosts
- The `BITBUCKET_WORKSPACE` value is correct
- For private repositories, the token is valid

---

## Important Notes

- Bitbucket Cloud projects may appear with a lock icon even when public
- This does **not** prevent integration with the DevPortal
- Public repositories work without a token
- Private repositories require an App Password
