# LDAP / Active Directory Example

This example demonstrates how to run VeeCode DevPortal locally with **LDAP authentication** and **LDAP org sync** against an **Active Directory**-compatible server.

A containerized Samba AD DC ([diegogslomp/samba-ad-dc](https://hub.docker.com/r/diegogslomp/samba-ad-dc)) is included in the Compose file so you can test the full flow without an external AD server.

The environment variable `VEECODE_PROFILE` is set to `ldap-ad`, which configures the DevPortal to:

- Authenticate users against the AD/LDAP server
- Sync users and groups into the DevPortal catalog

This example is intentionally scoped to **authentication and org sync only** (no other backend integrations involved).

References:

- LDAP auth plugin (source & behavior reference): <https://github.com/veecode-platform/devportal-plugins/blob/main/workspace/ldap-auth/README.md>
- LDAP profile docs (authoritative env vars): <https://docs.platform.vee.codes/devportal/installation-guide/docker-local/profiles/#ldap-profile>

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
| `BIND_NETWORK_INTERFACES` | `false` | Skips `bind interfaces only` with a veth name like `eth0@if…` on Docker bridge networks; without this, LDAP listens only on loopback and peer containers cannot connect. |

The container requires the `SYS_ADMIN` Linux capability (`cap_add`) so that Samba can set NT ACLs on the SYSVOL filesystem during provisioning.

If you previously started `dc1` **without** `BIND_NETWORK_INTERFACES=false`, the domain may have been provisioned with a broken `interfaces=` line in `smb.conf`. Run `docker compose down -v` once to recreate the named volumes, then `docker compose up` again.

Three named volumes (`dc1_etc`, `dc1_private`, `dc1_var`) persist the domain database across restarts.

### DevPortal LDAP settings

DevPortal connects to the Samba AD DC using standard LDAP environment variables:

| Variable | Value | Notes |
| --- | --- | --- |
| `LDAP_URL` | `ldap://dc1:389` | Container-to-container (port 389 inside `dc1`). From the host, LDAP is published as **8389** → 389 (`8389:389`). |
| `LDAP_DN` | `CN=Administrator,CN=Users,DC=samdom,DC=example,DC=com` | Bind DN (built-in domain Administrator from Samba provision) |
| `LDAP_SECRET` | `Passw0rd` | Must match `ADMIN_PASS` |
| `LDAP_USERS_BASE_DN` | `dc=samdom,dc=example,dc=com` | Search base for users |
| `LDAP_USERS_FILTER` | `(objectClass=user)` | AD user object class |
| `LDAP_GROUPS_BASE_DN` | `dc=samdom,dc=example,dc=com` | Search base for groups |
| `LDAP_GROUPS_FILTER` | `(objectClass=group)` | AD group object class |
| `LDAP_TLS_REJECT_UNAUTHORIZED` | `false` | Samba AD ships a self-signed cert; defaults to `true` in the profile |
| `LDAP_SYNC_FREQUENCY` | `PT2M` | Short interval so new `samba-tool` users appear without waiting an hour; defaults to `PT1H` |

> **Note:** The filters use AD-style object classes (`user`, `group`) instead of the OpenLDAP equivalents (`inetOrgPerson`, `groupOfNames`).

The `ldap-ad` profile (baked into the image) configures catalog auth and org sync with **Active Directory attributes** (`sAMAccountName`, AD object classes, `member`/`memberOf`). The stock `ldap` profile expects `uid` / `inetOrgPerson` and would fail against Samba AD.

You may see catalog **warnings** for built-in Windows groups whose display names contain spaces (Backstage entity names must match `[a-zA-Z0-9][-_.a-zA-Z0-9]*`). Tighten `LDAP_GROUPS_FILTER` if you want only your own groups.

## Running the Example

```bash
docker compose up --no-log-prefix
```

On first run, `dc1` will provision the Active Directory domain — this can take a minute or two. DevPortal may fail to connect until provisioning finishes; it will retry automatically.

The DevPortal will be available at: **<http://localhost:7007>**

### LDAP sign-in (important)

The auth plugin resolves the user with a single LDAP attribute: **`sAMAccountName`** (set by the `ldap-ad` profile).

- Use the **short logon name** only, e.g. **`johndoe`** — the same value as in `samba-tool user add johndoe`.
- Do **not** use the **UPN** (`johndoe@samdom.example.com`) or the **display name** (`John Doe`) in the username field; the lookup is `(sAMAccountName=<what you typed>)` and those values will not match.

If you prefer sign-in with UPN, override `usernameAttribute` to `userPrincipalName` in `app-config.local.yaml` and restart DevPortal (users must then type the full UPN).

**Catalog sync and login:** LDAP sign-in only succeeds if a **User** entity with `metadata.name` equal to your `sAMAccountName` already exists in the Backstage catalog (ingested by `LdapOrgEntityProvider`). If you **create AD users after** DevPortal has started, either wait for the next LDAP sync (this example sets `LDAP_SYNC_FREQUENCY=PT2M` — every 2 minutes) or run `docker compose restart devportal` once to force a refresh on startup.

## Managing Users and Groups

After the domain is provisioned you can use the `samba-tool` CLI inside the `dc1` container to create users and groups:

```bash
# Create a user
docker compose exec dc1 samba-tool user add johndoe --given-name=John --surname=Doe --mail-address=john@example.com
#Passw0rd
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
  -x -D "CN=Administrator,CN=Users,DC=samdom,DC=example,DC=com" -w Passw0rd -b "dc=samdom,dc=example,dc=com"
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
- **Wrong username on the sign-in form:** DevPortal logs may show `LdapAuthenticationError: user not found or usernameAttribute is wrong`. Use **`sAMAccountName`** (e.g. `johndoe`), not UPN or full name — see [LDAP sign-in](#ldap-sign-in-important) above.

`POST /api/auth/ldap/refresh` returning **401** with no session cookie is normal before you log in. **500** with the message above usually means the user lookup failed (username format) or bad password after the user was found.

### Resetting the domain

To start fresh, remove the named volumes:

```bash
docker compose down -v
```

## Next Steps

- Extend the profile by editing `app-config.local.yaml` (mounted into the container) and keep `VEECODE_PROFILE=ldap-ad`.
- For profile mechanics and merge order, see: <https://docs.platform.vee.codes/devportal/installation-guide/docker-local/profiles/>
