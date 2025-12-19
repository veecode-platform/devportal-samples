# Bitbucket Cloud – Quickstart (VeeCode DevPortal)

This quickstart shows how to configure **Bitbucket Cloud** integration in **VeeCode DevPortal** to:

- Import existing repositories into the Catalog
- Use Bitbucket actions in the Scaffolder

This setup is independent of any profile (`default`, `ldap`, etc).

---

## Prerequisites

- Docker Desktop (or compatible container engine)
- VeeCode DevPortal running locally
- A Bitbucket Cloud workspace
- At least one Bitbucket repository

---

## Environment Variables

Required:

```bash
export BITBUCKET_WORKSPACE=<your-bitbucket-workspace>
```


## docker-compose.yml

Add the variables to the DevPortal service:

```yaml
services:
  devportal:
    environment:
      - BITBUCKET_WORKSPACE=${BITBUCKET_WORKSPACE}
```

---

## Backend Configuration

The configuration below can be added to any backend-loaded config file, for example:

- `app-config.yaml`
- `app-config.production.yaml`
- `app-config.local.yaml`

---

## Bitbucket Cloud Integration

```yaml
integrations:
  bitbucket:
    - host: bitbucket.org
```


---


## Catalog Provider – Bitbucket Cloud (Required for Auto-Discovery)

```yaml
catalog:
  providers:
    bitbucket:
      development:
        workspace: ${BITBUCKET_WORKSPACE}
        token: ${BITBUCKET_TOKEN}

        catalogPath: /catalog-info.yaml

        schedule:
          frequency: PT1H
          timeout: PT15M
```

This provider will periodically scan all repositories in the workspace and import those containing a `catalog-info.yaml` file.

---



## Allow Reading from Bitbucket URLs

The backend must be allowed to read files from Bitbucket:

```yaml
backend:
  reading:
    allow:
      - host: bitbucket.org
      - host: api.bitbucket.org
      - host: www.bitbucket.org
```

---

## Import an Existing Repository into the Catalog

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
