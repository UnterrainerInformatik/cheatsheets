# Migration of Keycloak from pre 13 to latest
The version you're updating from is very old, so some inconveniences should be expected.
The upgrade-process is a simple 4-step process and you just have to change some environment-variables in between, which should be no problem.
Be sure to save your database, after shutting it down properly, between every step!
A local backup should suffice.

Personally I did this using dockerized MariaDB and dockerized Keycloak, which made things much faster, which was a very welcome circumstance, since getting a nice path through this mess was mainly a trial-and-error process.
Also, with this setup, the only place where changes in code will be manifested, is the mounted volume of the database, which makes saving and restoring, if something unexpected happens, a breeze.
# Known Problems
- none (till now)
## Upgrade to 13.0.1
Shut down you database.
Backup your database.
First upgrade to image: quay.io/keycloak/keycloak:13.0.1 without changing the config at all.
```bash
# The images' repository has changed and is available here instead.
# All future versions are available here as well.
# Here is the start of a typical docker-compose.yml for a Keycloak installation:
version: "3"
services:

  keycloak:
    image: quay.io/keycloak/keycloak:13.0.1
    container_name: keycloak
    restart: unless-stopped
    depends_on:
      - keycloak_db
    ports:
      - 12222:8080
    environment:
      # ...
```
Start it and see if the frontend starts correctly.
Save the database.

## Upgrade to 16.1.1
Shut down you database.
Backup your database.
Then upgrade to image: quay.io/keycloak/keycloak:16.1.1 without changing the config.
Start it and see if the frontend starts correctly.
Ignore the errors in the log (something about `InfinispanAuthenticationSessionProvider`).
Save the database.

## Upgrade to 18.0.2
Shut down you database.
Backup your database.
Change the config and upgrade to quay.io/keycloak/keycloak:18.0.2
```bash
environment:
#
# old config:
      - KEYCLOAK_USER=admin
      - KEYCLOAK_PASSWORD=${KEYCLOAK_PASSWORD}
      - DB_VENDOR=mariadb
      - DB_ADDR=keycloak_db
      - DB_DATABASE=keycloak
      - DB_USER=keycloak
      - DB_PASSWORD=${KEYCLOAK_DB_PASSWORD}
#      - PROXY_ADDRESS_FORWARDING=true
      - KEYCLOAK_HOSTNAME=keycloak.lan.elite-zettl.at
#    command: ["-b", "0.0.0.0", "-Dkeycloak.profile.feature.docker=enabled"]
#
# new config:
      - KC_HOSTNAME=keycloak.lan.elite-zettl.at
      - KC_HOSTNAME_BACKCHANNEL_DYNAMIC=false
      - KC_HTTP_ENABLED=true
      - KC_HOSTNAME_STRICT=false
      - KC_DB=mariadb
      - KC_DB_URL=jdbc:mariadb://keycloak_db:3306/keycloak?characterEncoding=UTF-8
      - KC_DB_USERNAME=keycloak
      - KC_DB_PASSWORD=${KEYCLOAK_DB_PASSWORD}
      - KEYCLOAK_ADMIN=admin
      - KEYCLOAK_ADMIN_PASSWORD=${KEYCLOAK_PASSWORD}
      - KC_HEALTH_ENABLED=true
      - KC_LOG_LEVEL=debug
      - KC_PROXY_HEADERS=xforwarded
      - PROXY_ADDRESS_FORWARDING=true
    command: start --auto-build --db=mariadb --http-relative-path /auth
# in the completely new config, auto-build is implied
# and thus no longer available.    
#start --db=mariadb --http-relative-path /auth
#
```
This fixes your `/auth` path, since that one got deleted from all URIs, but your clients don't know yet (the Keycloak-Server doesn't know either, but that's another story... it won't start with the new paths).
And it fixes the db-driver which is now pre-compiled by Quarkus, as well as the `/auth` URI and thus has to be specified during the build-step triggered by applying `auto-build`.
Start it and see if the frontend starts correctly.
Save the database.
This version is a mess as far as configuration is concerned... But don't worry, it's getting better.

## Upgrade to latest
Shut down you database.
Backup your database.
The latest Keycloak version as of this writing is `v25.0.1`.
So update the version to `latest` (don't do this in production. Always fix your versions in production!).
Then change the config to the new one:
```bash
environment:
#
# old config:
#      - KEYCLOAK_USER=admin
#      - KEYCLOAK_PASSWORD=${KEYCLOAK_PASSWORD}
#      - DB_VENDOR=mariadb
#      - DB_ADDR=keycloak_db
#      - DB_DATABASE=keycloak
#      - DB_USER=keycloak
#      - DB_PASSWORD=${KEYCLOAK_DB_PASSWORD}
#      - PROXY_ADDRESS_FORWARDING=true
#      - KEYCLOAK_HOSTNAME=keycloak.lan.elite-zettl.at
#    command: ["-b", "0.0.0.0", "-Dkeycloak.profile.feature.docker=enabled"]
#
# new config:
      - KC_HOSTNAME=keycloak.lan.elite-zettl.at
      - KC_HOSTNAME_BACKCHANNEL_DYNAMIC=false
      - KC_HTTP_ENABLED=true
      - KC_HOSTNAME_STRICT=false
      - KC_DB=mariadb
      - KC_DB_URL=jdbc:mariadb://keycloak_db:3306/keycloak?characterEncoding=UTF-8
      - KC_DB_USERNAME=keycloak
      - KC_DB_PASSWORD=${KEYCLOAK_DB_PASSWORD}
      - KEYCLOAK_ADMIN=admin
      - KEYCLOAK_ADMIN_PASSWORD=${KEYCLOAK_PASSWORD}
      - KC_HEALTH_ENABLED=true
      - KC_LOG_LEVEL=debug
      - KC_PROXY_HEADERS=xforwarded
      - PROXY_ADDRESS_FORWARDING=true
# in the completely new config, auto-build is implied
# and thus no longer available.
    command: start --db=mariadb --http-relative-path /auth
#
```
Then upgrade to image: quay.io/keycloak/keycloak:latest.
### After the first start (GUI may not work)
But the first start recompiled the internal Quarkus-build correctly and some important background-services have run.
The reason for the GUI not working is because they've simply added the `/auth`-part to the standard-URI, so your instance is no longer reachable under `your-keycloak-dns-name`, but `your-keycloak-dns-name/auth`. There is no automatic redirect in there.

You may now get rid of the command-parameters, which are no longer necessary:
```bash
#    command: start --db=mariadb --http-relative-path /auth
    command: start --http-relative-path ""
```

If you run into troubles because your browser is still redirecting to `/auth` at login, then try clearing your browsers' cache and, if that doesn't help, start Keycloak once with the parameter `command: start --http-relative-path ""` to rebuild Keycloak correctly. After that you may remove that parameter again so that the command-line reads `command: start` again. But for me that didn't work and I had to keep the empty relative path in. Maybe I made a mistake and it works anyway.

The new version picks up the `KC_DB` flag again, which is why you don't need the db-flag any longer, although Keycloak rebuilds every time on startup.

Of course this means, that you have to adapt all your clients now that you don't have the `http-relative-path` any more. But that should be expected, since this is a change to stay. It won't go away and your clients are better off if you fix this issue ASAP.
Alternatively you could still append the flag, which would fix the URI, but your clients will still be broken, since so much has changed since the version you've upgraded from and now you have to update your clients anyway.

## Tidy up
You now may get rid of all the commented-out lines in your `docker-compose.yml` and set the log-level to `info` again by specifying `- KC_LOG_LEVEL=info`.

## Debugging Hostname Issues & Admin Console Name
Add the following Quarkus-compiler-flag to your start-command in the `docker-compose.yml` file:
```bash
--hostname-debug=true
```

Then restart Keycloak. After startup go to the following URL and see the debug-output.
```bash
KEYCLOAK_BASE_URL/realms/master/hostname-debug
```
[Documentation](https://www.keycloak.org/server/hostname#_troubleshooting)
## User Federation an errors
If you've used user federation, the chances are that your setup won't be migrated gracefully. The most common error is that `validateUserPolicy` is enabled or that `writeMode` is not set.
In that case you'll have to go to the database and query the table `components` for `ldap` and then search for the fields in `component_config` and set them correctly.
## Useful Commands
Save/Reload Database:
```bash
# cd to the volume mapping, then
sudo cp -pr mysql-data/ mysql-data-save-16.1.1/
# Test the keycloak instance using only cURL
curl -d 'client_id=xxx' -d 'username=xxx' -d 'password=xxx' -d 'grant_type=password' 'https://keycloak.lan.co.at/realms/Cms/protocol/openid-connect/token'
```

## Post-Upgrade Issues
## Migrate your clients
Almost all of your clients will have an OIDC-Address somewhere, that has the `/auth/` part in it. Remove that from all clients since the OIDC-Endpoints are no longer available there, but at the same URL without the `/auth/` part.
## Migrate your servers
Same for the servers. Get rid of the `/auth/` in the OIDC-URL.
## Restart servers
Since servers get a asymmetrical key from the Keycloak server on startup that they use in their communication with the Keycloak server, you need to re-initialize the communication between your servers and Keycloak, since those keys are no longer valid now. Your server has to get a new one; Hence the restart.
## Migrate your login-themes
The directory your themes should be located in has changed from `/opt/jboss/keycloak/themes` to `/opt/keycloak/themes`, so change your volume mapping accordingly.
As far as I know nothing substantial has changed otherwise regarding themes, but I only used a login-theme. So I know nothing about the other ones. The templating engine hasn't changed for sure.