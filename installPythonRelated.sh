#!/bin/bash
if [[ "$(stat -c %d:%i /)" != "$(stat -c %d:%i /proc/1/root/. 2>/dev/null)" ]]; then
	IN_CHROOT=1
else
	IN_CHROOT=0
fi

SUDO=()
((IN_CHROOT)) || SUDO=(sudo)

BUILD_DIR="/usr/local/tahti/"
ROOTDIR="$BUILD_DIR/repos"

[ ! -d "$ROOTDIR" ] && { "${SUDO[@]}" mkdir -p "$ROOTDIR" && "${SUDO[@]}" chown tahti:tahti $BUILD_DIR && "${SUDO[@]}" chown tahti:tahti $ROOT_DIR; }
cd "$ROOTDIR"

#PYINDI_COMMIT="v2.1.2"

[ ! -d "/usr/local/tahti/venv" ] && { "${SUDO[@]}" python -m venv /usr/local/tahti/venv; }

cd "$ROOTDIR"
[ ! -d "pyindi-client" ] && { git clone https://github.com/indilib/pyindi-client.git || {
	echo "Failed to clone pyindi-client"
	exit 1
}; }
cd pyindi-client
git fetch origin
if [[ -n ${PYINDI_COMMIT-} ]]; then
	git switch -d --discard-changes $PYINDI_COMMIT
fi
"${SUDO[@]}" /usr/local/tahti/venv/bin/pip install setuptools
"${SUDO[@]}" /usr/local/tahti/venv/bin/python setup.py install || {
	echo "PYINDI installation failed"
	exit 1
}

"${SUDO[@]}" /usr/local/tahti/venv/bin/pip install python-pam six flask_cors PyJWT
"${SUDO[@]}" /usr/local/tahti/venv/bin/pip install --use-pep517 git+https://github.com/joxda/gps3.git git+https://github.com/knro/indiwebmanager.git git+https://github.com/joxda/pyINDI.git
"${SUDO[@]}" /usr/local/tahti/venv/bin/pip install flask_socketio gevent ephem
