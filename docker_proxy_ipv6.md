# Proxy-Einstellungen mit Docker

## System
```bash
sudo nano /etc/profile.d/proxy.sh
# Add
export ftp_proxy=ftp://user:password@host:port
export http_proxy=http://user:password@host:port
export https_proxy=https://user:password@host:port
export socks_proxy=https://user:password@host:port
```
## Apt
```bash
sudo nano /etc/apt/apt.conf
# Enter the following line
Acquire::http::Proxy "http://proxyserver.some.at:3128";
```
## WGet
```bash
sudo nano /etc/wgetrc
# enable the proxy-lines and enter the server accordingly.
https_proxy = http://proxyserver.some.at:3128/
http_proxy = http://proxyserver.some.at:3128/
ftp_proxy = http://proxyserver.some.at:3128/
```
## Docker Daemon
>Benötigt, um Images zu pullen.
```bash
sudo nano /etc/systemd/system/docker.service.d/http-proxy.conf
# Contents
[Service]
Environment="HTTP_PROXY=http://proxyserver.some.at:3128"
Environment="HTTPS_PROXY=http://proxyserver.some.at:3128"
# This is the place for proxy-exceptions...
Environment="NO_PROXY=localhost,127.0.0.1,docker-registry.example.com,.corp"
##########

# Then restart the docker daemon
sudo systemctl daemon-reload docker
sudo systemctl restart docker
```
## Docker Container
> Von innerhalb der erzeugten Container.
```bash
# Docker-user may be your main user or root.
sudo nano ~/.docker/config.json
# Contents
{
  "proxies": {
    "default": {
      "httpProxy": "http://username:password@proxy2.domain.com",
      "httpsProxy": "http://username:password@proxy2.domain.com"
    }
  }
}
##########
```
## DNS & IPv6
```bash
# Create an IPv6 network:
docker network create --ipv6 --subnet 2001:0DB8::/112 --gateway 2001:db8::1 ip6net
# And use it in the containers like so:
    ports:
      - "8080:8080"
      - "8443:8443"
    networks:
      - default
      - proxy
    environment:
      - HTTP_PORT=8080
# and at the end of the compose-file:
networks:
  default:
    external:
      name: ip6net
  proxy:
    external:
      name: proxy_default

# Enable IPv6 for docker in general:
sudo nano /etc/docker/daemon.json
# Contents:
{
  "experimental": true,
  "ip6tables": true,
  "dns": ["2001:67c:1434:1:195:149:240:141"]
}
```
## Test from inside container
```bash
# proxy config
env
# dns
ping google.at
dig google.at
curl google.at
wget google.at
```