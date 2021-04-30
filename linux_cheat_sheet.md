# README

## Misc

```bash
# Set screen resolution
xrandr -s 1920x1080
# See what Windows Manager you are using
echo $XDG_CURRENT_DESKTOP
# See what option you selected from the lightdm greeter to login.
echo $GDMSESSION

# Read compressed log-files
zcat /var/log/syslog.2.gz
# Grep for pattern and highlight, but don't omit no-match lines
cat /var/log/syslog | grep -E '^|rsnapshot'
# Grep for patterns and highlight, but don't omit no-match lines
cat /var/log/syslog | grep -E '^|rsnapshot|rsync'

# Set timezone
sudo timedatectl set-timezone Europe/Vienna
```

## Partition/Format Drive

```bash
sudo -s
```

```bash
apt-get update
apt-get install parted

dd if=/dev/zero of=/dev/sda bs=512 count=1 (check the device letter)
parted -s /dev/sda mklabel gpt 
parted -s /dev/sda mkpart primary ext4 4M 100%
partprobe /dev/sda

# Now we format:
mkfs.ext4 /dev/sda
sync

# Change drive label:
# ext2,3,4
tune2fs -L label /dev/sdb2
# btrfs
sudo btrfs filesystem label <device or mountpoint> <newlabel>

# Change the drives reserved space to zero:
# ext2,3,4
sudo tune2fs -m 0 /dev/sda

# And you're done. If you unplug and replug, XBMC will auto mount it, with a full 3TB available. This is verifiable with:
parted -s /dev/sda print

# Change UUID:
sudo tune2fs /dev/sde5 -U <uuid>
```

## Find Drive - Drive Info

```bash
# get a list of attached drives
df -h

# get info about attached drives with moundpoints, UUIDs and dev-name:
sudo blkid

# get info about device-events like connecting one:
dmesg

# get a list of connected usb devices:
lsusb
# get a verbose list:
lsusb -v
# display the list as tree (overrides v):
lsusb -t

# get drive info sorted by UUID like so:
ls -l /dev/disk/by-uuid
total 0
lrwxrwxrwx 1 root root 10 Jan  7 14:25 00dd0a12-a0a6-4322-aff4-f0365294138d -> ../../dm-1
lrwxrwxrwx 1 root root 10 Jan  7 14:25 38c7f7c5-2e2b-4983-bead-6a4062a3146f -> ../../sdc1
lrwxrwxrwx 1 root root 10 Jan  7 14:25 5F52-8B64 -> ../../sda1
lrwxrwxrwx 1 root root 10 Jan  7 14:25 92b6a434-8ccd-4eef-888f-0e5b85df199c -> ../../dm-0
lrwxrwxrwx 1 root root 10 Jan  7 14:25 b22cc427-1747-4a43-a13c-9a63e74cfc51 -> ../../sda2
lrwxrwxrwx 1 root root  9 Jan  7 14:25 c2023b82-aa2e-4e88-855a-f976966efa92 -> ../../sdb

```

## Mount Drive

```bash
sudo mount -a
# (mounts everything in fstab)

sudo fdisk -l
# (gets info about connected devices)

sudo mkdir /media/usbstick
# (tail -f /var/log/messages while plugging in to get the right dev)

sudo mount -t ext4 /var/sda1 /media/usbstick

sudo blkid /dev/sda
sudo nano -Bw /etc/fstab

# Change permissions:
sudo chmod 775 /mnt/usbdrive
# Change ownership:
sudo chown root:root /mnt/usbdrive
```

## Mount With Fstab

```bash
sudo blkid 

/dev/fd0: UUID="E0B4-1F9A" SEC_TYPE="msdos" TYPE="vfat"
/dev/sda1: UUID="10BF-F2D6" SEC_TYPE="msdos" TYPE="vfat"
/dev/sdb1: UUID="0000-0000" SEC_TYPE="msdos" TYPE="vfat"
# The floppy-disk has an UUID as well. Additionally the drive at /dev/sdb1 doesn't have a valid ID, so it is displayed as 0000-0000. You shouldn't mount these using the ID, use the label instead. An entry in /etc/fstab for /dev/sda1 could look like this:

UUID=10BF-F2D6     /media/usb1    auto    rw,user,noauto    0    0

# other examples:
UUID=85dc9154-54dd-4e3a-b888-ad17125486a9     /media/Backup1B1    ext4    defaults 0 0
UUID=38c7f7c5-2e2b-4983-bead-6a4062a3146f     /media/Backup1      ext4    defaults 0 0

```

## NFS - Server

```bash
sudo apt install nfs-kernel-server
# ...then make local dir you want to share...
sudo mkdir /mnt/share
sudo chmod 777 /mnt/share
sudo chown nobody:nogroup /mnt/share
# (important for nfs permission downgrading)
sudo nano /etc/exports
# Add a new share. Example:
  /mnt/share 10.0.0.0/255.0.0.0(rw,sync,no_subtree_check,no_root_squash)
  # (whereas the ip/mask combination are the allowed clients!)
  # and no_root_squash enables the target to call chown again.
sudo exportfs -a
# (really exports the nfs settings)
# if your firewall isn't off, you'll have to punch a hole through it for this service :)
sudo ufw status
```

## NFS - Client

```bash
sudo apt install nfs-common
# ...then make a local dir as mountpoint...
sudo mkdir /mnt/localshare
sudo mount <ip_or_name>:/mnt/share /mnt/localshare
# Example:
  sudo mount radagast.zebra-servers:/mnt/Backup1 /mnt/rada
  
# Example NFS mount in fstab (intr is deprecated and don't mount write-vols with soft):
radagast.zebra-servers:/mnt/Backup1             /mnt/backup     nfs     auto    0       0
```

## Samba

```bash
sudo nano /etc/samba/smb.conf
sudo /etc/init.d/samba restart
# or
sudo service smb restart

# add new samba user...
# first add it to the system with strong passwd
useradd <username>
# this is better since adduser will add a home-directory and useradd will not
# now add the user to the samba-list
# here you can add the samba-passwd
smbpasswd -a <username>

# SMB 4 and up...
# no need to create a local user any longer...
# but only if you use AD services and not standalone-samba-server.
# just do
sudo samba-tool user create USERNAME-HERE
# restart
sudo service smbd restart
```

## Check Drive

```bash
e2fsck -p -C 0 /dev/<device>
```
## Get Free Space On HDDs

```bash
df -h

# for directories
du -h -d 1 *
```
## Update Raspbian (drivers, ...)

```bash
sudo rpi-update
```

## Processes

```bash
sudo ps fuxwa
# (process representation with parent-indicator)
sudo ps aux
# (list of processes)
sudo ps aux | grep rsync
# (list of all processes containing 'rsync')
htop
# (graphical representation of all running tasks with CPU and MEM bars)
ctop
# (graphical representation of all running docker containers)

# To fully disconnect a program from the terminal where you launched it, use
nohup myprogram </dev/null >myprogram.log 2>&1 &

# also disconnect but close if parent (this terminal) closes:
myprogram &
# disconnect and also disconnect from parent process (front):
setsid myprogram
# same but back:
myprogram & disown
```

## Privileges

```bash
sudo nano /etc/sudoers
# Add the next line to allow the user 'pi' to sudo all commands without a password.
pi ALL=(ALL) NOPASSWD: ALL
```

## Filesystem

```bash
# Get the number of files in each sub-directory in the directory you're currently in.
find . -xdev -type d -print0 |
  while IFS= read -d '' dir; do
    echo "$(find "$dir" -maxdepth 1 -print0 | grep -zc .) $dir"
  done |
  sort -rn |
  head -50

#Get the number of files and directories
ls -1 | wc -l
# Get the number of files and directories in a nice tree representation.
tree .
# Find similar files in different directories (name may vary).
fdupes --recurse dir1 dir2
```

## Rsnapshot

```bash
# View schedule of installed srnapshot configs.
cat /etc/cron.d/rsnapshot
```

## Disable IPv6

```bash
# Add the 'link-local' line at the position like in the example below.
network:
    ethernets:
        enp0s2:
            link-local: []

# Then restart netplan.
sudo netplan apply
```

## Bash

```bash
# The shebang.
#!/bin/bash

# Parameter checking.
if [ "$#" -ne 2 ]; then
    echo "Illegal number of parameters. Use <param1> <param2>"
fi

# Setting variables for this script.
server=$1
db=$2
user=$3
pwd=$4

# Run other script.
. read_config.sh

# Build variables out of variables.
nbranch="${server}_${db}_this_month"
obranch="${server}_${db}_last_month"

# This is a function.
# Functions have to be declared before they can be called.
function this_is_a_function {
  echo "first parameter of function: $1"
  echo "first parameter of function: $2"
}

# If branch exists (pipe output to dev/null) then delete it and push the deleted branch (to delete it from upstream).
(git show-branch $1 &>/dev/null) && (git branch -D $1 && git push origin -d $1)

# If a succeeds (exit 0), then b, else c (a exits with >0).
(a) && (b) || (c)

# Call rotate.sh and pass all parameters passed to this script here.
/var/lib/mysqlbu/rotate.sh "$@"

# Exit with error.
exit 1
# Exit with success.
exit 0
```

```bash
# Lock via file (handle 200, can be any number) and exit if already locked.
exec 200>/tmp/rsync-to-unterrainer.lockfile
flock -n 200 || exit 1
~/rsyncToUnterrainerInformatik.sh
```

```bash
# Retry rsync until there is no error any longer.
RC=1 
while [[ $RC -ne 0 ]]
do
  /home/zebra/rsyncBackup1ToBackup1Weekly.sh 
  RC=$?
  if [[ $RC -ne 0 ]]; then
    _echo_i "Transfer disrupted (return code ${RC}), retrying in 10 seconds..."
    sleep 10
  fi
done
```

```bash
# Embed lodash (own library) from GitLab static link and open new script.
#!/bin/bash
source <(curl -s http://git.zebra-servers/dev-ops/scripts/raw/master/lobash.sh?private_token=Ki4mWMtvyaKJgNcnun4U)
_init

_echo_h "rsyncBackupToBackup1WeeklyLocked.sh"
```



### Config File Parser

```bash
# Configuration file parser.
# Replace <NAME_OF_YOUR_PROGRAM>.
# Load with . <filename_of_this> <filename_of_your_config> in the script you're gonna use it in.

shopt -s extglob
configfile="${1}" # set the actual path name of your (DOS or Unix) config file

tr -d '\r' < $configfile > .$configfile.unix
while IFS='= ' read lhs rhs
do
    if [[ ! $lhs =~ ^\ *# && -n $lhs ]]; then
        rhs="${rhs%%\#*}"    # Del in line right comments
        rhs="${rhs%%*( )}"   # Del trailing spaces
        rhs="${rhs%\"*}"     # Del opening string quotes 
        rhs="${rhs#\"*}"     # Del closing string quotes 
        if [[ $rhs == \(* && $rhs == *\) ]]; then 	# if opening and closing parenthesis...
	    declare -a $lhs="${rhs}" 			# Declare as array
	else
	    declare $lhs="$rhs" 			# Declare as variable
	fi
    fi
done < .$configfile.unix
```

### Example Config File

```bash
# The dir where mysqlbu will be installed
dir = /data/backup/mysqlbu

# The name of the repository containing the backup-data
repo = mysql-backup
# The upstream repository
upstream =ssh://git@git.zebra-servers:2222/dev-ops/backup/mysql-backup.git
# The commit message for the dumps
message="Daily backup."
# The file name of the dumps
file="dump.sql"
# This is an actual array (which is treated as such after parsing)
arr1=(1 2 3)
arr2 = ('one' 'two' '3')
```

## Chrome Remote Desktop and Ubuntu Desktop
```bash
# first install Ubuntu Desktop on the server without recommendations
sudo apt install --no-install-recommends ubuntu-desktop
# download the latest version of chrome-remote-desktop on the server
wget https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb
# install it
sudo dpkg -i chrome-remote-desktop_current_amd64.deb
sudo apt -f install
# now we have to authorize the new installation...
# follow the steps being displayed if you follow the next link on a computer
# running a viable installation of crome-remote-desktop with authentication...
https://remotedesktop.google.com/headless/
```

### References
- https://remotedesktop.google.com/headless/
- http://scode.github.io/docs/software/chrome_remote_desktop_ubuntu.html


## Remote Desktop Ubuntu - Windows

https://askubuntu.com/a/592544
