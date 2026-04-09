# LDAP / Active Directory Example

This example demonstrates how to run VeeCode DevPortal locally with **LDAP authentication** and **LDAP org sync** against an **Active Directory**-compatible server.

A containerized Samba AD DC ([diegogslomp/samba-ad-dc](https://hub.docker.com/r/diegogslomp/samba-ad-dc)) is included in the Compose file so you can test the full flow without an external AD server.

The environment variable `VEECODE_PROFILE` is set to `ldap`, which configures the DevPortal to:

- Authenticate users against the AD/LDAP server
- Sync users and groups into the DevPortal catalog

This example is intentionally scoped to **authentication and org sync only** (no other backend integrations involved).

References:

- LDAP auth plugin (source & behavior reference): https://github.com/veecode-platform/devportal-plugins/blob/main/workspace/ldap-auth/README.md
- LDAP profile docs (authoritative env vars): https://docs.platform.vee.codes/devportal/installation-guide/docker-local/profiles/#ldap-profile

## Overview

The Compose file starts two services:

- **`dc1`** — A Samba AD Domain Controller that emulates a Windows Active Directory server. It provisions the domain `SAMDOM.EXAMPLE.COM` on first run.
- **`devportal`** — VeeCode DevPortal configured to authenticate and sync users/groups from `dc1` over LDAP.

## Prerequisites

- Docker Desktop (or compatible container engine)

No external LDAP/AD server is required — the bundled Samba AD DC container provides one out of the box.

## How It Works

### Samba AD DC (`dc1`)

The `dc1` service runs Samba as an Active Directory Domain Controller. On first start it provisions a new domain with the following defaults (configured via environment variables in `docker-compose.yml`):

| Variable | Value |
| --- | --- |
| `REALM` | `SAMDOM.EXAMPLE.COM` |
| `DOMAIN` | `SAMDOM` |
| `ADMIN_PASS` | `Passw0rd` |
| `DNS_FORWARDER` | `8.8.8.8` |

The container requires the `SYS_ADMIN` Linux capability (`cap_add`) so that Samba can set NT ACLs on the SYSVOL filesystem during provisioning.

Three named volumes (`dc1_etc`, `dc1_private`, `dc1_var`) persist the domain database across restarts.

### DevPortal LDAP settings

DevPortal connects to the Samba AD DC using standard LDAP environment variables:

| Variable | Value | Notes |
| --- | --- | --- |
| `LDAP_URL` | `ldap://dc1:389` | Resolved via Docker Compose networking |
| `LDAP_DN` | `cn=admin,dc=samdom,dc=example,dc=com` | Bind DN (AD Administrator) |
| `LDAP_SECRET` | `Passw0rd` | Must match `ADMIN_PASS` |
| `LDAP_USERS_BASE_DN` | `dc=samdom,dc=example,dc=com` | Search base for users |
| `LDAP_USERS_FILTER` | `(objectClass=user)` | AD user object class |
| `LDAP_GROUPS_BASE_DN` | `dc=samdom,dc=example,dc=com` | Search base for groups |
| `LDAP_GROUPS_FILTER` | `(objectClass=group)` | AD group object class |

> **Note:** The filters use AD-style object classes (`user`, `group`) instead of the OpenLDAP equivalents (`inetOrgPerson`, `groupOfNames`).

## Running the Example

```bash
docker compose up --no-log-prefix
```

On first run, `dc1` will provision the Active Directory domain — this can take a minute or two. DevPortal may fail to connect until provisioning finishes; it will retry automatically.

The DevPortal will be available at: **http://localhost:7007**

## Managing Users and Groups

After the domain is provisioned you can use the `samba-tool` CLI inside the `dc1` container to create users and groups:

```bash
# Create a user
docker compose exec dc1 samba-tool user add johndoe --given-name=John --surname=Doe --mail-address=john@example.com

# Create a group
docker compose exec dc1 samba-tool group add developers
docker compose exec dc1 samba-tool group add backstage-admins

# Add a user to a group
docker compose exec dc1 samba-tool group addmembers backstage-admins johndoe

# List users
docker compose exec dc1 samba-tool user list

# List groups
docker compose exec dc1 samba-tool group list
```

You can use ldapsearch too:

```bash
ldapsearch -H ldap://localhost:8389 \
  -x -D "cn=admin,dc=samdom,dc=example,dc=com" -w Passw0rd -b "dc=samdom,dc=example,dc=com"
```


After creating users/groups, trigger an org sync in DevPortal (or wait for the next scheduled sync) to see them in the catalog.

## Troubleshooting

### `dc1` exits with "Access Denied"

The Samba provisioning process needs to set NT ACLs on the SYSVOL directory. Make sure the `dc1` service has `cap_add: [SYS_ADMIN]` (or `privileged: true`) in the Compose file.

### DevPortal cannot connect to LDAP

- Check that `dc1` has finished provisioning (`docker compose logs dc1`).
- Verify the LDAP URL uses the Compose service name (`ldap://dc1:389`).
- Confirm `LDAP_SECRET` matches the `ADMIN_PASS` set on `dc1`.

### Authentication fails

Common causes:

- Wrong `LDAP_DN` / `LDAP_SECRET` for the bind user
- Base DNs don't match the domain structure
- Filters don't match the AD schema (use `objectClass=user` / `objectClass=group` for AD)

### Resetting the domain

To start fresh, remove the named volumes:

```bash
docker compose down -v
```

## Next Steps

- If you need to override or extend the profile configuration, mount an `app-config.local.yaml` and keep `VEECODE_PROFILE=ldap`.
- For profile mechanics and merge order, see: https://docs.platform.vee.codes/devportal/installation-guide/docker-local/profiles/
