#!/bin/bash

BUILD_DIR="/usr/local/tahti/"
ROOTDIR="$BUILD_DIR/repos"

[ ! -d "$ROOTDIR" ] && { sudo mkdir -p "$ROOTDIR" && sudo chown tahti:tahti $BUILD_DIR && sudo chown tahti:tahti $ROOT_DIR; }
cd "$ROOTDIR"

PYINDI_COMMIT="v2.1.2"

[ ! -d "/usr/local/tahti/venv" ] && { sudo python -m venv /usr/local/tahti/venv --system-site-packages; }

cd "$ROOTDIR"
[ ! -d "pyindi-client" ] && { git clone https://github.com/indilib/pyindi-client.git || {
	echo "Failed to clone pyindi-client"
	exit 1
}; }
cd pyindi-client
if [ -n $PYINDI_COMMIT ] && [ $PYINDI_COMMIT != "master" ]; then
	git fetch origin
	git switch -d --discard-changes $PYINDI_COMMIT
else
	git pull origin
fi
sudo /usr/local/tahti/venv/bin/pip install setuptools
sudo /usr/local/tahti/venv/bin/python setup.py install || {
	echo "PYINDI installation failed"
	exit 1
}

sudo /usr/local/tahti/venv/bin/pip install python-pam six flask_cors PyJWT fastapi uvicorn
sudo /usr/local/tahti/venv/bin/pip install --use-pep517 git+https://github.com/joxda/gps3.git git+https://github.com/knro/indiwebmanager.git git+https://github.com/joxda/pyINDI.git
sudo /usr/local/tahti/venv/bin/pip install flask_socketio gevent ephem
