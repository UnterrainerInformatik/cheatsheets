# README

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
  /mnt/share 10.0.0.0/255.0.0.0(rw,sync,no_subtree_check)
  # (whereas the ip/mask combination are the allowed clients!)
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

## Remote Desktop Ubuntu - Windows

https://askubuntu.com/a/592544

