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





## Remote Desktop Ubuntu - Windows

https://askubuntu.com/a/592544

