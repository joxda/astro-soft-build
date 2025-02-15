#!/bin/bash

sudo pip install indiweb
sudo curl https://raw.githubusercontent.com/joxda/indiwebmanager/refs/heads/master/indiwebmanager.service -o /etc/systemd/system/indiwebmanager.service
sudo chmod 644 /etc/systemd/system/indiwebmanager.service

sudo curl https://raw.githubusercontent.com/joxda/indiwebmanager/refs/heads/master/tahti.rules -o /etc/udev/rules.d/tahti.rules

sudo curl https://raw.githubusercontent.com/joxda/indiwebmanager/refs/heads/master/resetOnstep.py -o /usr/local/bin/resetOnstep.py
sudo chmod 755 /usr/local/bin/Onstep.py




# gps related
sudo systemctl disable hciuart

sudo systemctl daemon-reload
sudo systemctl enable indiwebmanager.service
