#!/bin/bash

BUILD_DIR="/usr/local/tahti/"
ROOTDIR="$BUILD_DIR/repos"

[ ! -d "$ROOTDIR" ] && { sudo mkdir -p "$ROOTDIR" && sudo chown tahti:tahti $BUILD_DIR && sudo chown tahti:tahti $ROOT_DIR; }
cd "$ROOTDIR"


cd "$ROOTDIR"
[ ! -d "gpspanel" ] && { git clone https://github.com/joxda/gpspanel.git || { echo "Failed to clone gpspanel"; exit 1; } }
cd gpspanel
git fetch origin
git pull
sudo /usr/local/tahti/venv/bin/pip install -r requirements.txt
[ ! -d "/var/www/gpspanel" ] && { sudo mkdir /var/www/gpspanel; }
sudo cp -r ./* /var/www/gpspanel/

cd "$ROOTDIR"
[ ! -d "astropanel" ] && { git clone https://github.com/joxda/astropanel.git || { echo "Failed to clone astropanel"; exit 1; } }
cd astropanel
git fetch origin
git pull
sudo /usr/local/tahti/venv/bin/pip install -r requirements.txt
[ ! -d "/var/www/astrospanel" ] && { sudo mkdir /var/www/astropanel; } 
sudo cp	-r ./* /var/www/astropanel/

cd "$ROOTDIR"
[ ! -d "astroberry-server-wui" ] && { git clone -b j3 --single-branch https://github.com/joxda/astroberry-server-wui.git || { echo "Failed to clone astroberry-server-wui"; exit 1; } }
cd astroberry-server-wui
git fetch
git pull
sudo cp -r files/html/* /var/www/html/


