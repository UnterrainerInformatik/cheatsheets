# GPG Cheat Sheet

## Commands

### list keys

```bash
gpg --list-keys
```

### export keys

```bash
gpg --export-secret-keys -a 1234ABCD > secret.asc
# or
gpg --export-secret-keys keyIDNumber > exportedKeyFilename.asc
```

### edit keys

```bash
gpg --edit-key (keyIDNumber)

gpg> trust
Please decide how far you trust this user to correctly verify other users' keys
(by looking at passports, checking fingerprints from different sources, etc.)
  1 = I don't know or won't say
  2 = I do NOT trust
  3 = I trust marginally
  4 = I trust fully
  5 = I trust ultimately
  m = back to the main menu
```

### import keys

```bash
gpg --import mypub_key
gpg --allow-secret-key-import --import myprv_key
```