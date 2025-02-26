#!/bin/bash

export CFLAGS="-march=native -w -Wno-psabi -D_FILE_OFFSET_BITS=64"
export CXXFLAGS="-march=native -w -Wno-psabi -D_FILE_OFFSET_BITS=64"

CHECKOUT=0
BUILD_DIR="/usr/local/tahti/"
ROOTDIR="$BUILD_DIR/repos"

JOBS=$(grep -c ^processor /proc/cpuinfo)
# 64 bit systems need more memory for compilation
if [ $(getconf LONG_BIT) -eq 64 ] && [ $(grep MemTotal < /proc/meminfo | cut -f 2 -d ':' | sed s/kB//) -lt 5000000 ]
then
	echo "Low memory limiting to JOBS=2"
	JOBS=2
fi

[ ! -d "$ROOTDIR" ] && mkdir -p "$ROOTDIR"
cd "$ROOTDIR"

[ ! -d "libXISF" ] && { git clone https://gitea.nouspiro.space/nou/libXISF.git || { echo "Failed to clone LibXISF"; exit 1; } }
cd libXISF
git pull origin
[ ! -d ../build-libXISF ] && { cmake -B ../build-libXISF ../libXISF -DCMAKE_BUILD_TYPE=Release || { echo "LibXISF configuration failed"; exit 1; } }
cd ../build-libXISF
make -j $JOBS || { echo "LibXISF compilation failed"; exit 1; }
sudo make install || { echo "LibXISF installation failed"; exit 1; }

cd "$ROOTDIR"
[ ! -d "indi" ] && { git clone --depth=1 https://github.com/indilib/indi.git || { echo "Failed to clone indi"; exit 1; } }
cd indi
git pull origin
[ ! -d ../build-indi ] && { cmake -B ../build-indi ../indi -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release || { echo "INDI configuration failed"; exit 1; } }
cd ../build-indi
make -j $JOBS || { echo "INDI compilation failed"; exit 1; }
sudo make install || { echo "INDI installation failed"; exit 1; }

cd "$ROOTDIR"
[ ! -d "indi-3rdparty" ] && { git clone --depth=1 https://github.com/indilib/indi-3rdparty.git || { echo "Failed to clone indi 3rdparty"; exit 1; } }
cd indi-3rdparty
git pull origin
[ ! -d ../build-indi-lib ] && { cmake -B ../build-indi-lib ../indi-3rdparty -DCMAKE_INSTALL_PREFIX=/usr -DBUILD_LIBS=1 -DCMAKE_BUILD_TYPE=Release || { echo "INDI lib configuration failed"; exit 1; } }
cd ../build-indi-lib
make -j $JOBS || { echo "INDI lib compilation failed"; exit 1; }
sudo make install || { echo "INDI lib installation failed"; exit 1; }

[ ! -d ../build-indi-3rdparty ] && { cmake -B ../build-indi-3rdparty ../indi-3rdparty -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release || { echo "INDI lib configuration failed"; exit 1; } }
cd ../build-indi-3rdparty
make -j $JOBS || { echo "INDI 3rd-party compilation failed"; exit 1; }
sudo make install || { echo "INDI lib installation failed"; exit 1; }

cd "$ROOTDIR"
[ ! -d "stellarsolver" ] && { git clone --depth=1 https://github.com/rlancaste/stellarsolver.git || { echo "Failed to clone stellarsolver"; exit 1; } }
cd stellarsolver
git pull origin
[ ! -d ../build-stellarsolver ] && { cmake -B ../build-stellarsolver ../stellarsolver -DCMAKE_BUILD_TYPE=Release || { echo "Stellarsolfer configuration failed"; exit 1; } }
cd ../build-stellarsolver
make -j $JOBS || { echo "Stellarsolver compilation failed"; exit 1; }
sudo make install || { echo "Stellarsolver installation failed"; exit 1; }

cd "$ROOTDIR"
[ ! -d "kstars" ] && { git clone --depth=1 https://invent.kde.org/education/kstars.git || { echo "Failed to clone KStars"; exit 1; } }
cd kstars
git pull origin
[ ! -d ../build-kstars ] && { cmake -B ../build-kstars -DBUILD_TESTING=Off ../kstars -DCMAKE_BUILD_TYPE=Release || { echo "KStars configuration failed"; exit 1; } }
cd ../build-kstars
make -j $JOBS || { echo "KStars compilation failed"; exit 1; }
sudo make install || { echo "KStars installation failed"; exit 1; }

sudo ldconfig

[ "$1" != "phd2" ] && exit

cd "$ROOTDIR"
[ ! -d "phd2" ] && { git clone https://github.com/OpenPHDGuiding/phd2.git || { echo "Failed to clone PHD2"; exit 1; } }
cd phd2
git fetch origin
git switch -d --discard-changes "v2.6.12"
[ ! -d ../build-phd2 ] && cmake -B ../build-phd2 -DCMAKE_BUILD_TYPE=Release || { echo "PHD2 configuration failed"; exit 1; }
cd ../build-phd2
make -j $JOBS || { echo "PHD2 compilation failed"; exit 1; }
sudo make install

