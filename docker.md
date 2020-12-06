# Docker

## Installation

```bash
sudo apt install docker.io
```

### Post Installation
```bash
# post install general
sudo groupadd docker
sudo usermod -aG docker $USER
# next one is to avoid a re-login
newgrp docker
docker run hello-world
sudo systemctl enable docker

# post-install to run prune periodically
0 2 * * * /usr/bin/docker system prune -f 2>&1
```


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

# reload config (.json config files)
sudo systemctl daemon-reload

# Start docker again
sudo systemctl start docker
```
