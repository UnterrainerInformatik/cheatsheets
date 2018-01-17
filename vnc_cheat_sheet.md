# VNC on Linux
## Server

For a server we use `x11vnc` since it's the only server that is able to share your current desktop in an easy and understandable way.
Other VNC-server implementations open another instance of another graphical user interface remotely for you.

We use that without SSH since we only use VNC in our internal, controlled environment.
However, tunneling the data over SSH is of cause possible given some extra configuration.

### Install Script

#### Run 'as service' (persistent) installation

Installs all from-scratch.

Copy to a new sh-script. Give it execute permissions.
Execute it WITH `sudo`!

System will reboot!

```bash
# ##################################################################
# Script Name : vnc-startup.sh
# Description : Perform an automated install of X11Vnc
#               Configure it to run at startup of the machine            
# Date : Feb 2016
# Written by : Griffon 
# Web Site :http://www.c-nergy.be - http://www.c-nergy.be/blog
# Version : 1.0
#
# Disclaimer : Script provided AS IS. Use it at your own risk....
#
# #################################################################

# Step 1 - Install X11VNC  
# ################################################################# 
sudo apt-get install x11vnc -y

# Step 2 - Specify Password to be used for VNC Connection 
# ################################################################# 

sudo x11vnc -storepasswd /etc/x11vnc.pass 


# Step 3 - Create the Service Unit File
# ################################################################# 

cat > /lib/systemd/system/x11vnc.service << EOF
[Unit]
Description=Start x11vnc at startup.
After=multi-user.target

[Service]
Type=simple
ExecStart=/usr/bin/x11vnc -auth guess -forever -loop -scrollcopyrect -wireframe -nodragging -ncache 20 -ncache_cr -repeat -rfbauth /etc/x11vnc.pass -rfbport 5900 -shared
#ExecStart=/usr/bin/x11vnc -auth guess -forever -loop -noxdamage -ncache 10 -ncache_cr -repeat -rfbauth /etc/x11vnc.pass -rfbport 5900 -shared

[Install]
WantedBy=multi-user.target
EOF

# Step 4 -Configure the Service 
# ################################################################ 

echo "Configure Services"
sudo systemctl enable x11vnc.service
sudo systemctl daemon-reload

sleep  5s
sudo shutdown -r now 
```

Restart the service manually:

```bash
systemctl try-restart x11vnc.service
```



### Manual

#### Manual Install

```bash
# Install x11vnc
sudo apt-get install x11vnc
# Save a password for your connections (highly recommended)
#  If the directory doesn't exist yet, create it:
sudo mkdir ~/.vnc
x11vnc -storepasswd <password> ~/.vnc/passwd
```

#### Manual Test

```bash
# Start the server to test it
x11vnc -display :0
# If you want to leave it 'open' (it will close after disconnecting the first connection, then:
x11vnc -forever -ncache 10 -ncache_cr -display :0 -rfbauth ~/.vnc/passwd

# Now go to the machine you're running a viewer on and enter your computer's network-address there with the port 5900. Example:
10.66.66.150:5900
```



## Client

It's best to install RealVNC from their website. It's the most advanced interface there is (and the most stable as well).
```bash
# Go to their website

# Download it
# And install it using your favorite package manager
```
