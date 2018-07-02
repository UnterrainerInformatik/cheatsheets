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
```



## PARTITION/FORMAT DRIVE

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
tune2fs -L label /dev/sdb2

# Change the drives reserved space to zero:
sudo tune2fs -m 0 /dev/sda

# And you're done. If you unplug and replug, XBMC will auto mount it, with a full 3TB available. This is verifiable with:
parted -s /dev/sda print

# Change UUID:
sudo tune2fs /dev/sde5 -U <uuid>
```

## MOUNT DRIVE

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
sudo chmod 777 /mnt/usbdrive
# Change ownership:
sudo chown root:root /mnt/usbdrive
```

## MOUNT WITH FSTAB

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

## SAMBA

```bash
sudo nano /etc/samba/smb.conf
sudo /etc/init.d/samba restart
```

## CHECK DRIVE

```bash
e2fsck -p -C 0 /dev/<device>
```
## GET FREE SPACE

```bash
df -h
```
## UPDATE RASPBIAN (DRIVERS, ...)

```bash
sudo rpi-update
```

## PROCESSES

```bash
sudo ps fuxwa
# (process representation with parent-indicator)
sudo ps aux
# (list of processes)
sudo ps aux | grep rsync
# (list of all processes containing 'rsync')
ctop
# (graphical representation of all running tasks with CPU and MEM bars)
```

## PRIVILEGES

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

## RSNAPSHOT

```bash
# View schedule of installed srnapshot configs.
cat /etc/cron.d/rsnapshot
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





## 



## Remote Desktop Ubuntu - Windows

https://askubuntu.com/a/592544

