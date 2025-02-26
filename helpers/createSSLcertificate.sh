#!/bin/bash
openssl req -x509 -nodes -days 365 -newkey rsa:4096 \
   -keyout /usr/local/tahti/key.pem \
   -out /usr/local/tahti/self.pem \
   -subj "/C=US/ST=State/L=City/O=Company/CN=tahti.local/emailAddress=admin@tahti.local"
