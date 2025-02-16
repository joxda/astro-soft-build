#!/bin/bash

sudo mkdir -p /usr/local/indiweb
sudo python -m venv /usr/local/indiweb/venv
sudo /usr/local/indiweb/venv/bin/pip install indiweb requests==2.32.2 psutil bottle==0.12.25 importlib_metadata==8.5.0


sudo curl https://raw.githubusercontent.com/joxda/indiwebmanager/refs/heads/master/indiwebmanager.service -o /etc/systemd/system/indiwebmanager.service
sudo chmod 644 /etc/systemd/system/indiwebmanager.service

sudo curl https://raw.githubusercontent.com/joxda/indiwebmanager/refs/heads/master/tahti.rules -o /etc/udev/rules.d/tahti.rules

sudo curl https://raw.githubusercontent.com/joxda/indiwebmanager/refs/heads/master/resetOnstep.py -o /usr/local/bin/resetOnstep.py
sudo chmod 755 /usr/local/bin/resetOnstep.py


[ ! -d "/etc/selfsigned/" ] && sudo mkdir /etc/selfsigned/
sudo openssl req -new -x509 -days 365 -nodes -out /etc/selfsigned/self.pem -keyout /etc/selfsigned/key.pem -subj "/C=FI/ST=PP/L=Oulu/O=-/OU=taht.local/emailAddress=admin@tahti.local"



[ ! -d "gpspanel" ] && { git clone https://github.com/joxda/gpspanel.git || { echo "Failed to clone gpspanel"; exit 1; } }
cd gpspanel
git fetch origin
git pull
sudo /usr/local/indiweb/venv/bin/pip install -r requirements.txt
sudo cp gpspanel.service /etc/systemd/system/
cd ..
sudo cp -r gpspanel /var/www/

[ ! -d "astropanel" ] && { git clone https://github.com/joxda/astropanel.git || { echo "Failed to clone astropanel"; exit 1; } }
cd astropanel
git fetch origin
git pull
sudo /usr/local/indiweb/venv/bin/pip install -r requirements.txt
sudo cp	astropanel.service /etc/systemd/system/
cd ..
sudo cp	-r astropanel /var/www/
sudo cp tahti.nginx.config /etc/nginx/sites-available
[ -f /etc/nginx/site-enabled/default ] && sudo rm /etc/nginx/site-enabled/default
[ ! -f /etc/nginx/sites-enabled/tahti.nginx.config ] && sudo ln /etc/nginx/sites-available/tahti.nginx.config /etc/nginx/sites-enabled







# gps related
sudo cp nmea_fake /usr/local/share/
sudo cp gps-fallback.py /usr/local/bin/
sudo chmod 755 /usr/local/bin/gps-fallback.py
sudo cp gps-fallback.service /etc/systemd/system/
sudo systemctl disable hciuart
sudo raspi-config nonint do_vnc 0 
sudo raspi-config nonint do_serial_cons 1
sudo raspi-config nonint do_serial_hw 0

sudo cp wayvnc.config /etc/wayvnc/config
sudo cp noVnc.service /etc/systemd/system/

sudo systemctl daemon-reload
sudo systemctl enable indiwebmanager.service
sudo systemctl enable gpsd
sudo systemctl enable gps-fallback.service
sudo systemctl enable noVnc.service
sudo systemctl enable gpspanel.service
sudo systemctl enable astropanel.service
