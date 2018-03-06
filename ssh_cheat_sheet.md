# SSH Cheat Sheet

## Step 1 - Setup public SSH keys

On our origin server, we will generate public SSH keys with no password:

```bash
ssh-keygen -f ~/.ssh/id_rsa -q -P ""
cat ~/.ssh/id_rsa.pub
```

This is our public SSH key that can be placed on other hosts to give us access:

```bash
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDLVDBIpdpfePg/a6h8au1HTKPPrg8wuTrjdh0QFVPpTI4KHctf6/FGg1NOgM++hrDlbrDVStKn/b3Mu65//tuvY5SG9sR4vrINCSQF++a+YRTGU6Sn4ltKpyj3usHERvBndtFXoDxsYKRCtPfgm1BGTBpoSl2A7lrwnmVSg+u11FOa1xSZ393aaBFDSeX8GlJf1SojWYIAbE25Xe3z5L232vZ5acC2PJkvKctzvUttJCP91gbNe5FSwDolE44diYbNYqEtvq2Jt8x45YzgFSVKf6ffnPwnUDwhtvc2f317TKx9l2Eq4aWqXTOMiPFA5ZRM/CF0IJCqeXG6s+qVfRjB root@cloudads
```

Copy this key to your clipboard and login to your destination server.

Place this SSH key into your ~/.ssh/authorized_keys file:

If your SSH folder does not exist, create it manually:

```bash
mkdir ~/.ssh
chmod 0700 ~/.ssh
touch ~/.ssh/authorized_keys
chmod 0644 ~/.ssh/authorized_keys
```

Alternatively you can use this command to copy the local key to the remote server:

```bash
ssh-copy-id -i ~/.ssh/mykey user@host
# Example for a key called servers_rsa.pub and radagast:
# The 'comment' in the public key is arbitrary. Feel free to change that with your favorite text editor before copying it to the server:
ssh-copy-id -i ~/code/ssh/servers_rsa.pub zebra@radagast.zebra-servers
# Then you have to authenticate yourself in order for the copy operation to succeed.
```



### Multiple Local RSA Keys

From `.ssh/config`:

```bash
Host myshortname realname.example.com
    HostName realname.example.com
    IdentityFile ~/.ssh/realname_rsa # private key for realname
    User remoteusername

Host myother realname2.example.org
    HostName realname2.example.org
    IdentityFile ~/.ssh/realname2_rsa
    User remoteusername
```

## PUTTYgen

In order to use the public key in PUTTY and to connect to a linux host in that way, you have to convert it from OpenSSH format (.pem) to putty-format (.ppk).

In order to do that, start PUTTYgen, load your OpenSSH key and choose 'save public key as...' and save it as .ppk file.

Import that in putty and add it under 'auth' in the connection preferences. When logging in, you just have to specify the right username and you're connected.

## rsync

```bash
sudo rsync -avrPe "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i $HOME/.ssh/epsilon3_rsa -p 65493" --rsync-path="sudo rsync" -avRHP --delete /mnt/Backup1/ pi@www.unterrainer.info:/mnt/Backup1B1 >> /var/log/rsyncToUnterrainerInformatik.log 2>&1
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

### Stacking Executions As cron job

When executing as cron job the script could be started a second time, although the last instance is already running (because it didn't finish by now). To circumvent that, you can use a lock-file.

Write a wrapper-script that calls your original script like so:

```bash
flock -n /tmp/rsync-to-unterrainer.lockfile ~/rsyncToUnterrainerInformatik.sh
# The -n option tells it to just abort the new instance if no lock could be obtained.
```

Now let's build a cron job for that wrapper.

```bash
crontab -e
# Edits the cron-file for the current user
crontab -u <user_name> -e
# Edits the cron-file for the given user

# Add to log to dev/null (error&stdout): > /dev/null 2>&1
# Add log to syslog:  | /usr/bin/logger -t <command_display_name>
#    you then can follow it with tail -f /var/log/syslog
00 23 * * TUE /home/zebra/rsyncToUnterrainerInformatikLocked.sh | /usr/bin/logger -t copy_backup_to_unterrainer
# (starts every 23:00 on every tuesday)
*/05 * * * * /home/zebra/rsyncToUnterrainerInformatikLocked.sh | /usr/bin/logger -t copy_backup_to_unterrainer
# (starts every 5 minutes)
```

Now you can watch the script at work, along with the error output, by tailing the syslog.

And you can see if the script is currently running with:

```bash
ll /tmp
# As long as the file rsync-to-unterrainer.lockfile is present, no other task will start
```

