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
sudo crontab -e
0 2 * * * /usr/bin/docker system prune -f 2>&1

# if you'd like to use special DNS servers from within
# your containers, then do the following:
sudo nano /etc/docker/daemon.json
# and add the following:
{
  "dns": ["192.168.16.5" , "192.168.16.6"]
}
# where the IPs are from your DNS servers.
# They will be used from within containers started on your host.
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
