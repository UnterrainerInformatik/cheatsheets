# SSL Cheat Sheet

## Commands

### Delete a certificate from a Java Keytool keystore

```bash
keytool -delete -alias mydomain -keystore keystore.jks
```

### Change a Java keystore password

```bash
keytool -storepasswd -new new_storepass -keystore keystore.jks
```

### Export a certificate from a keystore

```bash
keytool -export -alias mydomain -file mydomain.crt -keystore keystore.jks
```

### List Trusted CA Certs

```bash
keytool -list -v -keystore c:/data/server/stash/cacerts
```



## IMPORTANT

### Import New CA into Trusted Certs

```bash
keytool -import -trustcacerts -file /path/to/ca/ca.pem -alias CA_ALIAS -keystore c:/data/server/stash/cacerts
```

### List certs

```bash
keytool -list -keystore c:/data/server/stash/cacerts
```

### Other stuff

```bash
keytool -v -importkeystore -srckeystore mycert.co.in.p12 -srcstoretype PKCS12 -destkeystore mycert.co.in.jks -deststoretype JKS

keytool -changealias -alias old_name -destalias new_name -keystore c:/data/server/stash/cacerts

keytool -keypasswd -new changeit -keystore c:/data/server/stash/cacerts -storepass changeit -alias someapp -keypass password
```



## Checklist (works):

```bash
# get .p12 file from StartSSL
# import .p12 file using
keytool -import -trustcacerts -file /path/to/ca/ca.pem -alias CA_ALIAS -keystore c:/data/server/stash/cacerts
#rename newly imported cert (should have a number) to the desired name using
keytool -changealias -alias old_name -destalias new_name -keystore c:/data/server/stash/cacerts
# set pwd of the imported key to the same as for the keystore using (if you have a different password defined)
keytool -keypasswd -new changeit -keystore c:/data/server/stash/cacerts -storepass changeit -alias someapp -keypass password
```



## Import DER file (didn't work):

```bash
# Validate the root certificate content
keytool -v -printcert -file ca.der
# Import the root certificate into the JVM trust store
keytool -importcert -alias startssl -keystore c:/data/server/stash/cacerts -storepass changeit -file ca.der
		# (the default password for the CA store is changeit)
		# The keytool will prompt you for confirmation, enter yes to complete the operation.
# Verify that the root certificate has been imported
keytool -keystore "c:/data/server/stash/cacerts" -storepass changeit -list | grep startssl
```
