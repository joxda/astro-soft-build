#!/bin/bash
if [[ "$(stat -c %d:%i /)" != "$(stat -c %d:%i /proc/1/root/. 2>/dev/null)" ]]; then
  IN_CHROOT=1
else
  IN_CHROOT=0
fi

SUDO=()
(( IN_CHROOT )) || SUDO=(sudo)


BUILD_DIR="/usr/local/tahti/"
ROOTDIR="$BUILD_DIR/repos"

[ ! -d "$ROOTDIR" ] && { "${SUDO[@]}" mkdir -p "$ROOTDIR" && "${SUDO[@]}" chown tahti:tahti $BUILD_DIR && "${SUDO[@]}" chown tahti:tahti $ROOT_DIR; }
cd "$ROOTDIR"

#TAGS/COMMITS!!
cd "$ROOTDIR"
[ ! -d "gpspanel" ] && { git clone https://github.com/joxda/gpspanel.git || { echo "Failed to clone gpspanel"; exit 1; } }
cd gpspanel
git fetch origin
git pull
"${SUDO[@]}" /usr/local/tahti/venv/bin/pip install -r requirements.txt
[ ! -d "/var/www/gpspanel" ] && { "${SUDO[@]}" mkdir /var/www/gpspanel; }
"${SUDO[@]}" cp -r ./* /var/www/gpspanel/

cd "$ROOTDIR"
[ ! -d "astropanel" ] && { git clone https://github.com/joxda/astropanel.git || { echo "Failed to clone astropanel"; exit 1; } }
cd astropanel
git fetch origin
git pull
"${SUDO[@]}" /usr/local/tahti/venv/bin/pip install -r requirements.txt
[ ! -d "/var/www/astrospanel" ] && { "${SUDO[@]}" mkdir /var/www/astropanel; } 
"${SUDO[@]}" cp	-r ./* /var/www/astropanel/

cd "$ROOTDIR"
[ ! -d "tahtiOS-webUI" ] && { git clone -b j3 --single-branch https://github.com/joxda/tahtiOS-webUI.git || { echo "Failed to clone tahtiOS-webUI"; exit 1; } }
cd tahtiOS-webUI
git fetch
git pull
"${SUDO[@]}" cp -r files/html/* /var/www/html/


