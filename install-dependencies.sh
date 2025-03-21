#!/bin/bash

sudo apt update && sudo apt upgrade

sudo apt -y install libnova-dev libcfitsio-dev libusb-1.0-0-dev zlib1g-dev libgsl-dev build-essential cmake git \
        libjpeg-dev libcurl4-gnutls-dev libtiff-dev libfftw3-dev libftdi-dev libgps-dev libraw-dev libdc1394-dev libgphoto2-dev \
        libboost-dev libboost-regex-dev librtlsdr-dev liblimesuite-dev libftdi1-dev libavcodec-dev libavdevice-dev \
        libeigen3-dev extra-cmake-modules libkf5plotting-dev libqt5svg5-dev libkf5xmlgui-dev libkf5kio-dev kinit-dev \
        libkf5newstuff-dev libkf5doctools-dev libkf5notifications-dev qtdeclarative5-dev libkf5crash-dev gettext libkf5notifyconfig-dev \
        wcslib-dev libqt5websockets5-dev xplanet xplanet-images qt5keychain-dev libsecret-1-dev breeze-icon-theme qml-module-qtquick-controls \
        pkg-config libev-dev libqt5datavisualization5-dev libzmq3-dev

sudo apt -y install emacs libopencv-dev python3-opencv gpredict gpsd gpsd-clients python3-gps pps-tools ntp dnsutils swig novnc websockify nginx ufw # lazarus-ide (astap)

[ "$1" == "phd2" ] && sudo apt -y install libwxgtk3.2-dev

