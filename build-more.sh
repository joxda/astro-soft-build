#!/bin/bash

BUILD_DIR="/usr/local/tahti/"
ROOTDIR="$BUILD_DIR/repos"

[ ! -d "$ROOTDIR" ] && { sudo mkdir -p "$ROOTDIR" && sudo chown tahti:tahti $BUILD_DIR && sudo chown tahti:tahti $ROOT_DIR; }
cd "$ROOTDIR"

PYINDI_COMMIT="v2.1.2"

[ ! -d "/usr/local/tahti/venv" ] && { sudo python -m venv /usr/local/tahti/venv; }

cd "$ROOTDIR"
[ ! -d "pyindi-client" ] && { git clone https://github.com/indilib/pyindi-client.git || { echo "Failed to clone pyindi-client"; exit 1; } }
cd pyindi-client
git fetch origin
git switch -d --discard-changes $PYINDI_COMMIT
sudo /usr/local/tahti/venv/bin/python setup.py install || { echo "PYINDI installation failed"; exit 1; }

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

sudo /usr/local/tahti/venv/bin/pip install python-pam six flask_cors PyJWT
sudo /usr/local/tahti/venv/bin/pip install --use-pep517 git+https://github.com/joxda/gps3.git git+https://github.com/knro/indiwebmanager.git git+https://github.com/joxda/pyINDI.git


