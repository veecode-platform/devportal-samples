# LDAP Example

This example demonstrates how to run VeeCode DevPortal locally with **LDAP authentication** and **LDAP org sync** enabled.

The environment variable `VEECODE_PROFILE` is set to `ldap`, which configures the DevPortal to:

- Authenticate users against your LDAP server
- Sync users and groups into the DevPortal catalog

This example is intentionally scoped to **authentication and org sync only** (no other backend integrations involved).

References:

- LDAP auth plugin (source & behavior reference): https://github.com/veecode-platform/devportal-plugins/blob/main/workspace/ldap-auth/README.md
- LDAP profile docs (authoritative env vars): https://docs.platform.vee.codes/devportal/installation-guide/docker-local/profiles/#ldap-profile

## Overview

This setup provides:

- User sign-in via LDAP
- Automatic import/sync of users and groups (org data) from LDAP

It does **not** configure repository discovery or SCM integrations.

## Prerequisites

- Docker Desktop (or compatible container engine)
- Access to an LDAP server (OpenLDAP or Active Directory)
- An LDAP bind DN (service account) with permission to read users and groups

## Required Environment Variables

This example uses the **LDAP profile** (`VEECODE_PROFILE=ldap`).

Required:

- `LDAP_URL` - LDAP server URL, e.g. `ldap://ldap.example.com:389`
- `LDAP_DN` - Bind DN (distinguished name), e.g. `cn=admin,dc=vee,dc=codes`
- `LDAP_SECRET` - Bind password
- `LDAP_USERS_BASE_DN` - Users base DN, e.g. `ou=People,dc=vee,dc=codes`
- `LDAP_GROUPS_BASE_DN` - Groups base DN, e.g. `ou=Groups,dc=vee,dc=codes`

Optional (recommended to set explicitly so behavior is obvious):

- `LDAP_USERS_FILTER` - Defaults to `(uid=*)`
- `LDAP_GROUPS_FILTER` - Defaults to `(objectClass=groupOfNames)`

## Setup

### Option A (recommended): Run a temporary local LDAP server with `vkdr`

If you don’t already have an LDAP server available, you can spin up a disposable local OpenLDAP with a known user/group structure using the `vkdr` CLI (the same approach used by the upstream LDAP auth plugin workspace).

1. Start the local infrastructure (with nodeports enabled):

```bash
vkdr infra start --nodeports=2
```

2. Install nginx ingress (default ingress controller):

```bash
vkdr nginx install --default-ic
```

3. Install OpenLDAP (including an admin user):

```bash
vkdr openldap install --ldap-admin
```

Sanity check the directory with `ldapsearch`:

```bash
ldapsearch -H ldap://localhost:9000 \
	-x -D "cn=admin,dc=vee,dc=codes" -w admin -b "dc=vee,dc=codes"
```

If installed by `vkdr`, the web UI (phpLDAPadmin) should be available at:

- http://ldap.localhost:8000/

This `vkdr` OpenLDAP setup is meant for local testing/dev only.

### Option B: Use an existing LDAP server

If you already have LDAP/AD, you only need a bind DN with read permissions over users and groups.

### 1. Confirm your LDAP structure

You’ll need to know:

- Where users live in your directory (users base DN)
- Where groups live (groups base DN)
- Which attribute(s) identify a user (commonly `uid` in OpenLDAP, often different in AD)

If you’re using OpenLDAP and want a reference implementation of a local directory structure for testing, see the upstream plugin README:

- https://github.com/veecode-platform/devportal-plugins/blob/main/workspace/ldap-auth/README.md

### 2. Export environment variables

Example values for the `vkdr` OpenLDAP setup above (adjust to your directory if using a different server):

```bash
export LDAP_URL="ldap://localhost:9000"
export LDAP_DN='cn=admin,dc=vee,dc=codes'
export LDAP_SECRET='admin'

export LDAP_USERS_BASE_DN='ou=People,dc=vee,dc=codes'
export LDAP_GROUPS_BASE_DN='ou=Groups,dc=vee,dc=codes'

# Optional (defaults shown here)
export LDAP_USERS_FILTER='(uid=*)'
export LDAP_GROUPS_FILTER='(objectClass=groupOfNames)'
```

## Running the Example

### Start DevPortal

```bash
docker compose up --no-log-prefix
```

The DevPortal will be available at: **http://localhost:7007**

## Troubleshooting

### Missing Environment Variables

If you see LDAP-related errors during startup or login, confirm what the container is receiving:

```bash
env | grep '^LDAP_'
```

### Authentication fails

Common causes:

- Wrong `LDAP_DN` / `LDAP_SECRET` for the bind user
- Firewall / network access to `LDAP_URL`
- Base DNs don’t match the directory tree
- Filters don’t match your LDAP schema

## Next Steps

- If you need to override or extend the profile configuration, mount an `app-config.local.yaml` and keep `VEECODE_PROFILE=ldap`.
- For profile mechanics and merge order, see: https://docs.platform.vee.codes/devportal/installation-guide/docker-local/profiles/

