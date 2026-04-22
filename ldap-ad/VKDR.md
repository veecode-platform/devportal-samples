# VKDR LDAP-AD Testing

Testing LDAP-AD integration with VKDR.

## Start Samba-AD

```bash
docker compose up dc1 --no-log-prefix
```

## Create Users and Groups

```bash
# Create a user
docker compose exec dc1 samba-tool user add johndoe --given-name=John --surname=Doe --mail-address=john@example.com
# Create a group
docker compose exec dc1 samba-tool group add developers
docker compose exec dc1 samba-tool group add backstage-admins
# Add a user to a group
docker compose exec dc1 samba-tool group addmembers backstage-admins johndoe
```

## Start VKDR

```bash
vkdr infra up
```

## Start DevPortal

```bash
vkdr devportal install --merge values-vkdr.yaml
```
