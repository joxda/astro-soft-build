#!/bin/bash
 
# onstep and rules are specific (and it would be the wrong place)
sudo cp helpers/tahti.rules /etc/udev/rules.d

# also schedule to renew? script certificate?

git pull

# nginx
sudo cp configs/tahti.*nginx.config /etc/nginx/sites-available
[ -f /etc/nginx/site-enabled/default ] && { sudo rm /etc/nginx/site-enabled/default; }

# update
#sudo cp /var/www/html/panels.html /var/www/html/index.html ## different one or set in the nginx config
#sudo cp /usr/share/novnc/vnc.html /usr/share/novnc/index.html

sudo cp helpers/* /usr/local/tahti
sudo chmod 755 /usr/local/tahti/*.py
sudo chmod 755 /usr/local/tahti/*.sh


# gps related
# use conf file instead
[ ! -f /usr/local/tahti/virtualgps.conf ] && { sudo cp configs/virtualgps.conf /usr/local/tahti/; }


# stuff below should be mostly more like a one time setup and not run with every update?
sudo systemctl disable hciuart

sudo raspi-config nonint do_vnc 0 
sudo raspi-config nonint do_serial_cons 1
sudo raspi-config nonint do_serial_hw 0

sudo mkdir -p /etc/wayvnc/
sudo cp configs/wayvnc.config /etc/wayvnc/config

sudo cp services/*.service /etc/systemd/system/

sudo systemctl daemon-reload
sudo systemctl enable indiwebmanager.service
sudo systemctl enable gpsd
sudo systemctl enable gps-fallback.service
sudo systemctl enable noVnc.service
sudo systemctl enable gpspanel.service
sudo systemctl enable astropanel.service
sudo systemctl enable pointing.service
sudo systemctl enable auth.service
sudo systemctl enable pyclient.service


# Enable UFW (if not enabled already)
#ufw enable
# Allow INDI server port (default 7624)
#ufw allow 7624/tcp
# Allow SSH (optional, if you need remote access)
#ufw allow ssh
# Default firewall settings: deny incoming, allow outgoing
#ufw default deny incoming
#ufw default allow outgoing

#ufw enable --force

