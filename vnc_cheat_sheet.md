# VNC/RDP/x2go on Linux

## Get the desktop environment you're currently using
```bash
echo $XDG_CURRENT_DESKTOP
# Tells you what Windows Manager you are using
echo $GDMSESSION
# Tells you what option you selected from the lightdm greeter to login.
```
# x11vnc
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
systemctl try-restart x11vnc.service
```

You may have to restart once for the changes to take effect.
Restart the service manually:

```bash
systemctl try-restart x11vnc.service
```

For Ubuntu you have to switch to XOrg as window manager (the default is Wayland on 17.04 for example).
For that to happen you have to log-out and then log-in again. On the login-screen, next to the login button, there is a cogwheel. When you select that, you can chose a window manager.

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
# XRDP
```bash
sudo apt install xrdp
# Check Installation
xrdp -v
# Should print:
#xrdp: A Remote Desktop Protocol server.
#Copyright (C) Jay Sorg 2004-2014
#See http://www.xrdp.org for more information.
#Version 0.9.1
sudo nano /etc/xrdp/startwm.sh
# Comment out the last two lines and add one like here:
#test -x /etc/X11/Xsession && exec /etc/X11/Xsession
#exec /bin/sh /etc/X11/Xsession
budgie-desktop
# Now save the file and exit nano.

#By default, the xRDP login screen should be using the actual keyboard layout you are using.  However, inside the remote session, the English layout keyboard is still defined as default and not changed automatically. To try to set the proper keyboard layout within your remote session, you can execute the following commands.

# Set keyboard layout in xrdp sessions 
cd /etc/xrdp 
test=$(setxkbmap -query | awk -F":" '/layout/ {print $2}') 
echo "your current keyboard layout is.." $test
setxkbmap -layout $test 
sudo cp /etc/xrdp/km-0409.ini /etc/xrdp/km-0409.ini.bak 
sudo xrdp-genkeymap km-0409.ini

```
# x2go
This remote desktop protocol is very fast. As far as I can tell it's proprietary and the best thing about is, that it works all over SSH.
So it's pretty secure and access is granted by simply creating an SSH user.
Rule of thumb is: If you can SSH to that machine via that user, you can x2go there too.

The connecting user of course has to enter the user-credentials.
## Server
```bash
# Add the x2go repository
sudo add-apt-repository ppa:x2go/stable -y

# Update the repositories
sudo apt-get update

# Add necessary software
sudo apt-get install -y x2goserver x2goserver-xsession

# Update the system
sudo apt-get update
sudo apt-get upgrade -y
# Optionally remove any unused packages
sudo apt-get autoremove -y
sudo apt-get clean
```
## Client
```bash
# Install x2go PPA
sudo add-apt-repository ppa:x2go/stable
sudo apt-get update

# Install necessary software
sudo apt-get install x2goclient

# Update the system
sudo apt-get update
sudo apt-get upgrade -y
# Optionally remove any unused packages
sudo apt-get autoremove -y
sudo apt-get clean
```

