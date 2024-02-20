#!/bin/sh

# Variables below are automatically edited by `run.sh`
DOMAIN_NAME="mydomain.com"
USER_MAIL="john@doe.com"

sleep 5

# Checking for the existence of a certificate for the domain and renewing it if necessary.
if [ ! -d "/etc/letsencrypt/live/$DOMAIN_NAME" ]; then
    echo "Obtaining a new certificate for $DOMAIN_NAME"
    certbot certonly --webroot -w /var/www -d $DOMAIN_NAME --email $USER_MAIL --agree-tos --non-interactive
else
    echo "Renewing the certificate for $DOMAIN_NAME"
    certbot renew
fi

echo "Refreshing Nginx configuration"
cat /etc/nginx/nginx.conf.bak > /etc/nginx/nginx.conf
echo "Nginx configuration refresh completed!"

nginx -s reload
