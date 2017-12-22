# Scheduled Hibernation for Ubuntu

## Prerequisites

```bash
sudo apt install powermanagement-interface
sudo apt install pm-utils
```

## Make A Script File

```bash
# In your user's home dir
touch hibernate_for_hours.sh
sudo chmod 777 hibernate_for_hours.sh
nano hibernate_for_hours.sh
```

## Bash Script

```bash
#!/bin/bash
# This script puts the system under standby mode for x hours
usage() {
echo "usage: $0 <n-hours>"
echo "where <n-hours> is the number of hours to be on standby"
exit 0

}
if [ $# -ne 1 ]
then
usage
fi

PATH=$PATH:/usr/sbin
hours=$1
echo 0 > /sys/class/rtc/rtc0/wakealarm
echo `date '+%s' -d "+ $hours hours"` > /sys/class/rtc/rtc0/wakealarm
# Edit the above line to get the exact length of hibernation you want
## For example echo `date '+%s' -d "+ $hours minutes"` to get minutes.
/usr/bin/logger -t HibernateForHours Hibernating for $hours hours now.
pm-suspend
# ...needs sudo rights as well as the write-op to wakealarm
# so start this script with sudo
```

## Schedule It

In order to do this right, the script should be executed as using `sudo` and we don't want anyone to have to enter the password later on. So we want this command in the `sudoers` file. But in there it has to be specified WITH all arguments. So it's best to write a wrapper for that script.

### daily_hibernate.sh

```bash
/home/<user>/hibernate_for_hours.sh 10
```

### wrapper_daily_hibernate.sh

```bash
sudo /home/<user>/daily_hibernate.sh
```

### weekend_hibernate.sh

```bash
/home/<user>/hibernate_for_hours.sh 58
```

### wrapper_weekend_hibernate.sh

```bash
sudo /home/<user>/weekend_hibernate.sh
```

## Cron Job

```bash
chrontab -e
### now change the file... add those lines and save/quit
00 20 * * 1-4 /home/<user>/wrapper_daily_hibernate.sh
00 20 * * 5 /home/<user>/wrapper_weekend_hibernate.sh
```

## Security Issues

Your `crontab` script contains a `sudo` call now

```bash
sudo nano /etc/sudoers
# add the following lines:
<user> ALL=NOPASSWD:/home/<user>/daily_hibernate.sh
<user> ALL=NOPASSWD:/home/<user>/weekend_hibernate.sh
```

You need that because the script needs to be run as a `sudoer` and this mechanism only looks for string-equality (doesn't 'see' arguments... it's all a string to it). This `sudo` command is executed in the wrapper-scripts, which are scheduled.

You're done!