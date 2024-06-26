# Let's Encrypt

### Nginx: set up a LetsEncrypt SSL certificate with auto-renewal in 3 easy steps
Unless you have been living under a rock for the past year, you should know by now that you can get SSL certificates free of charge from [LetsEncrypt](https://www.letsencrypt.org/), without registration, and with automatic renewal! This is one of the best thing that's happened to web admins and the web in general in the recent years. The certificates are authentic and work great in all browsers (you get the little green lock icon like everywhere else).

Let's get straight to the point. The three steps are summarized here:

1) Download LetsEncrypt (the application) for your Linux server
2) Run the application to generate a certificate for your domain and set up the monthly auto-renew cron job
3) Add the certificate to your Nginx configuration.
### Step 1: download LetsEncrypt
Install git if you haven't done so yet:
```bash
apt-get install git
```

Use git to get the application and store it somewhere (ie: /root/temp)
```bash
git clone <https://github.com/letsencrypt/letsencrypt>/root/temp/letsencrypt
```
### Step 2: generate your certificate
The first time you run the command below, you will be asked to provide an e-mail address to be associated to the domain or subdomain, in case you should ever need to recover the key or something. The next time you run the same command (to renew the certificate) it won't be asked.

So run the following command to generate the certificate:
```bash
/root/temp/letsencrypt/letsencrypt-auto certonly -a webroot --agree-tos --renew-by-default --webroot-path=**XXX **-d **YYY**

# Where: **XXX **is the full path to your website's root folder.
# For example /home/www/website.com
```
And **YYY** is the domain name or subdomain name (ie: [website.com](http://website.com/), or [something.website.com](http://something.website.com/))

At the time of running the command, your domain must be available to visitors already, because LetsEncrypt's servers will make a verification to ascertain that you are actually the owner of the domain. It will place a hidden /.well-known/ folder with some files in it at the root of your web directory (specified above with --webroot-path).

Certificates generated by LetsEncrypt are valid 3 months at the moment. Also, wildcards are not supported; you can get certificates for domain names and subdomains one by one. Since we don't want to manually renew the certificate every month for every domain and subdomain, **we can set up a simple cron job to be ran monthly** (it should be run every 3 months ideally but LetsEncrypt are talking about reducing the validity of their certificates so I'd rather not be caught off guard).

Open /etc/cron.monthly and create a new file, make sure to chmod +x to give executable permissions. The first line of the file should be:
```bash
!/bin/sh
```

And then put the exact same command you ran before to generate the certificate. You can also add  >>/root/temp/certificate-update.log at the end of the command if you want to keep a log of the updates (although I imagine LetsEncrypt generates its own log somewhere too).

### Step 3: configuring Nginx
After running the command that generates the certificates, you should have several files in `/etc/letsencrypt/live/website.com/` (replace [website.com](http://website.com/) by your own domain). We are going to need just two of them for Nginx: fullchain.pem and privkey.pem.

The beginning of your server block should look like this:
```bash
server {
 server_name [www.website.com](http://www.website.com/) [website.com](http://website.com/);
 listen 443 ssl;
 **ssl_certificate /etc/letsencrypt/live/website.com/fullchain.pem;**
** ssl_certificate_key /etc/letsencrypt/live/website.com/privkey.pem;**
** ssl_session_cache shared:SSL:20m;**
 [...]
```

Don't forget that last line, otherwise Safari and iOS devices won't be able to visit your website (see my [recent blog post about it](http://cnedelcu.blogspot.hk/2016/07/nginx-and-letsencrypt-ssl-certificate-safari-ios-problem.html)). Save configuration, reload, visit your site and voila, you're done. To make sure the automatic renewal script works, try running it now with the new configuration.