#!/bin/bash

sudo mkdir -p /usr/local/indiweb
sudo python -m venv /usr/local/indiweb/venv
sudo /usr/local/indiweb/venv/bin/pip install indiweb requests==2.32.2 psutil bottle==0.12.25 importlib_metadata==8.5.0
sudo curl https://raw.githubusercontent.com/joxda/indiwebmanager/refs/heads/master/indiwebmanager.service -o /etc/systemd/system/indiwebmanager.service
sudo chmod 644 /etc/systemd/system/indiwebmanager.service

sudo curl https://raw.githubusercontent.com/joxda/indiwebmanager/refs/heads/master/tahti.rules -o /etc/udev/rules.d/tahti.rules

sudo curl https://raw.githubusercontent.com/joxda/indiwebmanager/refs/heads/master/resetOnstep.py -o /usr/local/bin/resetOnstep.py
sudo chmod 755 /usr/local/bin/resetOnstep.py


# gps related
sudo cp nmea_fake /usr/local/share/
sudo cp gps-fallback.py /usr/local/bin/
sudo chmod 755 /usr/local/bin/gps-fallback.py
sudo cp gps-fallback.service /etc/systemd/system/
sudo systemctl disable hciuart
sudo raspi-config nonint do_vnc 0 
sudo raspi-config nonint do_serial_cons 1
sudo raspi-config nonint do_serial_hw 0

sudo systemctl daemon-reload
sudo systemctl enable indiwebmanager.service
sudo systemctl enable gpsd
sudo systemctl enable gps-fallback.service
