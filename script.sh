#!/bin/bash
#set -x #echo on

# CREATE NGINX CONFIG FILE
DIRLETS="/dockerize/letsencrypt/"

if [ -d "$DIRLETS" ]; then
echo "Nginx Docker for Let's Encrypt ##OK##"
else
mkdir $DIRLETS/TEMP
mkdir $DIRLETS/DATA
#mkdir $DIRLETS/

read -p 'Domain Name: (not include www.) '  domainvar

# CREATE NGINX CONFIG FILE 

echo "server {
listen 80;
listen [::]:80;
server_name $domainvar www.$domainvar;

location ~ /.well-known/acme-challenge {
allow all;
root /usr/share/nginx/html;
}

root /usr/share/nginx/html;
index index.html;
}
" >> $DIRLETS/TEMP/nginx.conf

# CREATE INDEX TEST PAGE

echo "<!DOCTYPE html>
<html>
<head>
<title>Let's Encrypt First Time Cert Issue Site</title>
</head>
<body>
<h1>Need Let's Encrypt WEBPAGE $domainvar & www.$domainvar!</h1>
</body>
</html>
" >> $DIRLETS/TEMP/index.html

# CREATE NGINX CONTAINER FOR LETSENCRYPT

echo "version: '3.1'
services:
     letnginx:
       container_name: 'letnginx'
       image: nginx:latest
       ports:
         - "80:80"
       volumes:
         - $DIRLETS/TEMP/nginx.conf:/etc/nginx/conf.d/default.conf
         - $DIRLETS/TEMP/index.html:/usr/share/nginx/html/index.html
" >> $DIRLETS/TEMP/docker-compose.yml

# CREATE INDEX TEST PAGE
cd $DIRLETS/TEMP/

docker-compose up -d

fi

#if [ -d "$DIRLETS" ]; then
# Take action if $DIRLETS exists. #
#echo "Let's Encrypt already Installed  ##OK##"
#else
# Control will jump here if $DIRLETS does NOT exists #
read -p 'Email: (for renew certificate) '  emailvar
chmod 600 /dockerize/letsencrypt/PROVIDER/ovh.ini
docker run -it --rm --name certbot \
  -v "/dockerize/letsencrypt/DATA:/etc/letsencrypt" \
  -v "/dockerize/letsencrypt/PROVIDER/ovh.ini:/ovh.ini" \
  certbot/dns-ovh \
  certonly \
  --dns-ovh \
  --dns-ovh-credentials /ovh.ini \
  --email "$emailvar" \
  --non-interactive \
  --agree-tos \
  --dns-ovh-propagation-seconds 60 \
  -d $domainvar
