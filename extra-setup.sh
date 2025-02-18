#!/bin/bash

sudo apt -y install emacs libopencv-dev python3-opencv gpredict gpsd gpsd-clients python3-gps pps-tools ntp dnsutils swig novnc websockify nginx #certbot python3-certbot-nginx 

# this is specific (and it would be the wrong place)
sudo cp helpers/tahti.rules /etc/udev/rules.d
sudo cp helpers/resetOnstep.py /usr/local/tahti/
sudo chmod 755 /usr/local/tahti/resetOnstep.py

# as part of first run script? better place?
[ ! -d "/etc/selfsigned/" ] && { sudo mkdir /etc/selfsigned/; }
sudo openssl req -new -x509 -days 365 -nodes -out /etc/selfsigned/self.pem -keyout /etc/selfsigned/key.pem -subj "/C=FI/ST=PP/L=Oulu/O=-/OU=taht.local/emailAddress=admin@tahti.local"
# also schedule to renew?

git pull

# nginx
sudo cp configs/tahti.nginx.config /etc/nginx/sites-available
[ -f /etc/nginx/site-enabled/default ] && { sudo rm /etc/nginx/site-enabled/default; }
[ ! -f /etc/nginx/sites-enabled/tahti.nginx.config ] && { sudo ln /etc/nginx/sites-available/tahti.nginx.config /etc/nginx/sites-enabled; }

# update
sudo cp /var/www/html/panels.html /var/www/html/index.html ## different one or set in the nginx config
sudo cp /usr/share/novnc/vnc.html /usr/share/novnc/index.html

sudo cp helpers/auth.py /usr/local/tahti
sudo cp configs/virtualgps.conf /usr/local/tahti


# gps related
# use conf file instead
sudo cp configs/virtualgps.conf /usr/local/tahti/
sudo cp helpers/gps-fallback.py /usr/local/tahti/
sudo chmod 755 /usr/local/tahti/gps-fallback.py

sudo systemctl disable hciuart

sudo raspi-config nonint do_vnc 0 
sudo raspi-config nonint do_serial_cons 1
sudo raspi-config nonint do_serial_hw 0

sudo cp configs/wayvnc.config /etc/wayvnc/config
sudo cp services/*.service /etc/systemd/system/


sudo systemctl daemon-reload
sudo systemctl enable indiwebmanager.service
sudo systemctl enable gpsd
sudo systemctl enable gps-fallback.service
sudo systemctl enable noVnc.service
sudo systemctl enable gpspanel.service
sudo systemctl enable astropanel.service
sudo systemctl enable auth.service
