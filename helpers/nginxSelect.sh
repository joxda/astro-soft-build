#!/bin/bash
CERT_FILE="/usr/local/tahti/self.pem"
KEY_FILE="/usr/local/tahti/key.pem"
CONFIG_FILE="/etc/nginx/sites-available/tahti.nginx.config"
CONFIG_SSL_FILE="/etc/nginx/sites-available/tahti.ssl.nginx.config"
LINK_NAME="/etc/nginx/sites-enabled/tahti.config"

if [[ -f "$CERT_FILE" && -f "$KEY_FILE" ]]; then
   ln -f -s $CONFIG_SSL_FILE $LINK_NAME
else
   ln -f -s $CONFIG_FILE $LINK_NAME   
fi
