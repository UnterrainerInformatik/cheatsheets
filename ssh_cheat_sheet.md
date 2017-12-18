# SSH Cheat Sheet

## Step 1 - Setup public SSH keys

On our origin server, we will generate public SSH keys with no password:

```
ssh-keygen -f ~/.ssh/id_rsa -q -P ""
cat ~/.ssh/id_rsa.pub
```

This is our public SSH key that can be placed on other hosts to give us access:

```
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDLVDBIpdpfePg/a6h8au1HTKPPrg8wuTrjdh0QFVPpTI4KHctf6/FGg1NOgM++hrDlbrDVStKn/b3Mu65//tuvY5SG9sR4vrINCSQF++a+YRTGU6Sn4ltKpyj3usHERvBndtFXoDxsYKRCtPfgm1BGTBpoSl2A7lrwnmVSg+u11FOa1xSZ393aaBFDSeX8GlJf1SojWYIAbE25Xe3z5L232vZ5acC2PJkvKctzvUttJCP91gbNe5FSwDolE44diYbNYqEtvq2Jt8x45YzgFSVKf6ffnPwnUDwhtvc2f317TKx9l2Eq4aWqXTOMiPFA5ZRM/CF0IJCqeXG6s+qVfRjB root@cloudads
```

Copy this key to your clipboard and login to your destination server.

Place this SSH key into your ~/.ssh/authorized_keys file:

If your SSH folder does not exist, create it manually:

```
mkdir ~/.ssh
chmod 0700 ~/.ssh
touch ~/.ssh/authorized_keys
chmod 0644 ~/.ssh/authorized_keys
```

## PUTTYgen

In order to use the public key in PUTTY and to connect to a linux host in that way, you have to convert it from OpenSSH format (.pem) to putty-format (.ppk).

In order to do that, start PUTTYgen, load your OpenSSH key and choose 'save public key as...' and save it as .ppk file.

Import that in putty and add it under 'auth' in the connection preferences. When logging in, you just have to specify the right username and you're connected.

## rsync

```bash
rsync -avrPe "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i $HOME/.ssh/epsilon3_rsa -p 65493" --progress /mnt/Backup1/* pi@www.unterrainer.info:/mnt/Backup1B1
```

### Security Issues

For `rsync` to be able to copy all data in that partition that could come from `rsnapshot` for instance, you'll have do `sudo` the `rsync` call. Otherwise you won't have the permission to read the files on your backup volume since the data there comes from many different users and the user-privileges  

To be able to do that in a script (otherwise it would prompt you for a password, which would be moot since it's a script), you have to change the `/etc/sudoers` list so that the `sudo` call to `rsync` on your copy-source location (where you start the script) doesn't need a password-entry.

```bash
# Let's say your user running the script will be 'zebra'...
sudo nano /etc/sudoers
# Add the following line:
zebra ALL=NOPASSWD:/usr/bin/rsync
# Then you're able to change your script to:
sudo rsync -avrPe "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i $HOME/.ssh/epsilon3_rsa -p 65493" --rsync-path="sudo rsync" --progress /mnt/Backup1/* pi@www.unterrainer.info:/mnt/Backup1B1
```

