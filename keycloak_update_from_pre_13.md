# Migration of Keycloak from pre 13 to latest
The version you're updating from is very old, so some inconveniences should be expected.
The upgrade-process is a simple 4-step process and you just have to change some environment-variables in between, which should be no problem.
Be sure to save your database, after shutting it down properly, between every step!
A local backup should suffice.

Personally I did this using dockerized MariaDB and dockerized Keycloak, which made things much faster, which was a very welcome circumstance, since getting a nice path through this mess was mainly a trial-and-error process.
## Upgrade to 13.0.1
Shut down you database.
Backup your database.
First upgrade to image: quay.io/keycloak/keycloak:13.0.1 without changing the config at all.
Start it and see if the frontend starts correctly.
Save the database.
## Upgrade to 16.1.1
Shut down you database.
Backup your database.
Then upgrade to image: quay.io/keycloak/keycloak:16.1.1 without changing the config.
Start it and see if the frontend starts correctly.
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
The latest Keycloak version as of this writing is `v25.0.0`.
So update the version to `latest`.
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
    command: start
```

The new version picks up the `KC_DB` flag again, which is why you don't need the db-flag any longer, although Keycloak rebuilds every time on startup.

Of course this means, that you have to adapt all your clients now that you don't have the `http-relative-path` any more. But that should be expected, since this is a change to stay. It won't go away and your clients are better off if you fix this issue ASAP.
Alternatively you could still append the flag, which would fix the URI, but your clients will still be broken, since so much has changed since the version you've upgraded from and now you have to update your clients anyway.
## Tidy up
You now may get rid of all the commented-out lines in your `docker-compose.yml` and set the log-level to `info` again by specifying `- KC_LOG_LEVEL=debug`.
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
## Useful Commands
Save/Reload Database:
```bash
# cd to the volume mapping, then
sudo cp -pr mysql-data/ mysql-data-save-16.1.1/
```
