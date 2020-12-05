# Docker

## Installation

## Reload Start, Stop, Restart

```bash
# reload config (.json config files)
sudo systemctl daemon-reload

# stop daemon
sudo systemctl stop docker
# start daemon
sudo systemctl start docker
```

## Move data-dir (/var/lib/docker)

```bash
# Stop docker daemon
sudo systemctl stop docker

# make new data-dir
sudo mkdir /new/path/docker
# copy old data (optional)
sudo rsync -aqxP /var/lib/docker/ /new/path/docker

# Edit/Create daemon.json file
sudo nano /etc/docker/daemon.json
# Should contain the following:
{
    "data-root": "/tmp/var-docker"
}

# Start docker again
sudo systemctl start docker
```
