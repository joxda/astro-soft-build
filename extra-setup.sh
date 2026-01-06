#!/bin/bash
if [[ "$(stat -c %d:%i /)" != "$(stat -c %d:%i /proc/1/root/. 2>/dev/null)" ]]; then
	IN_CHROOT=1
else
	IN_CHROOT=0
fi

SUDO=()
((IN_CHROOT)) || SUDO=(sudo)

# onstep and rules are specific (and it would be the wrong place)
"${SUDO[@]}" cp helpers/tahti.rules /etc/udev/rules.d

# also schedule to renew? script certificate?

git pull

# nginx
"${SUDO[@]}" cp configs/tahti.*nginx.config /etc/nginx/sites-available
[ -f /etc/nginx/site-enabled/default ] && { "${SUDO[@]}" rm /etc/nginx/site-enabled/default; }

# update
#sudo cp /var/www/html/panels.html /var/www/html/index.html ## different one or set in the nginx config
#sudo cp /usr/share/novnc/vnc.html /usr/share/novnc/index.html

"${SUDO[@]}" cp helpers/* /usr/local/tahti
"${SUDO[@]}" chmod 755 /usr/local/tahti/*.py
"${SUDO[@]}" chmod 755 /usr/local/tahti/*.sh

# gps related
# use conf file instead
[ ! -f /usr/local/tahti/virtualgps.conf ] && { "${SUDO[@]}" cp configs/virtualgps.conf /usr/local/tahti/; }

# stuff below should be mostly more like a one time setup and not run with every update?
#"${SUDO[@]}" systemctl disable hciuart

if command -v raspi-config >/dev/null 2>&1; then
	"${SUDO[@]}" raspi-config nonint do_vnc 0
	"${SUDO[@]}" raspi-config nonint do_serial_cons 1
	"${SUDO[@]}" raspi-config nonint do_serial_hw 0
fi

"${SUDO[@]}" cp configs/wayvnc.config /etc/wayvnc/config

"${SUDO[@]}" cp services/*.service /etc/systemd/system/

"${SUDO[@]}" systemctl daemon-reload
"${SUDO[@]}" systemctl enable indiwebmanager.service
"${SUDO[@]}" systemctl enable gpsd
"${SUDO[@]}" systemctl enable gps-fallback.service
"${SUDO[@]}" systemctl enable noVnc.service
"${SUDO[@]}" systemctl enable gpspanel.service
"${SUDO[@]}" systemctl enable astropanel.service
"${SUDO[@]}" systemctl enable pointing.service
"${SUDO[@]}" systemctl enable auth.service
"${SUDO[@]}" systemctl enable pyclient.service
