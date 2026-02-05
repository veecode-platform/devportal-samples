# KeyCloak Auth (Phase2)

Configure a realm properly in Phase2 as shown in the [Keycloak example](../../keycloak/README.md).

Set the env vars:

```bash
export KEYCLOAK_BASE_URL=.....
export KEYCLOAK_REALM=.....
export KEYCLOAK_CLIENT_ID=.....
export KEYCLOAK_CLIENT_SECRET=.....
export AUTH_SESSION_SECRET=.....
```

And run the install script:

```bash
./install.sh
```

Open <http://localhost:8000> in your browser.

You should be able to login with your Phase2 credentials.
