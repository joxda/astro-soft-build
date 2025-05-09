#!/bin/bash

#export CFLAGS="-march=native -w -Wno-psabi -D_FILE_OFFSET_BITS=64"
#export CXXFLAGS="-march=native -w -Wno-psabi -D_FILE_OFFSET_BITS=64"

LIBXISF_COMMIT="v0.2.13"
INDI_COMMIT="v2.1.2"
INDI_3RD_COMMIT="v2.1.2"
STELLAR_COMMIT="157092d6f843fb987818bd61f0b14b440eca3146"
KSTARS_COMMIT="origin/stable-3.7.5"
PHD2_COMMIT "v2.6.12"

BUILD_DIR="/usr/local/tahti/"
ROOTDIR="$BUILD_DIR/repos"

JOBS=$(grep -c ^processor /proc/cpuinfo)

# 64 bit systems need more memory for compilation
if [ $(getconf LONG_BIT) -eq 64 ] && [ $(grep MemTotal < /proc/meminfo | cut -f 2 -d ':' | sed s/kB//) -lt 5000000 ]
then
	echo "Low memory limiting to JOBS=2"
	JOBS=2
fi

[ ! -d "$ROOTDIR" ] && sudo mkdir -p "$ROOTDIR" && sudo chown tahti:tahti $ROOTDIR && sudo chown tahti:tahti $BUILD_DIR 
cd "$ROOTDIR"

[ ! -d "libXISF" ] && { git clone --depth 1 https://github.com/joxda/libXISF.git || { echo "Failed to clone LibXISF"; exit 1; } }
cd libXISF
if [ -n $LIBXISF_COMMIT ] && [ $LIBXISF_COMMIT != "master" ]; then
  git fetch origin
  git fetch --tags
  git switch -d --discard-changes $LIBXISF_COMMIT
else
	git pull origin
fi
[ ! -d ../build-libXISF ] && { cmake -B ../build-libXISF ../libXISF -DCMAKE_BUILD_TYPE=Release || { echo "LibXISF configuration failed"; exit 1; } }
cd ../build-libXISF
make -j $JOBS || { echo "LibXISF compilation failed"; exit 1; }
sudo make install || { echo "LibXISF installation failed"; exit 1; }

cd "$ROOTDIR"
[ ! -d "indi" ] && { git clone --depth 1 https://github.com/indilib/indi.git || { echo "Failed to clone indi"; exit 1; } }
cd indi
if [ -n $INDI_COMMIT ] && [ $INDI_COMMIT != "master" ]; then
	git fetch origin
    git fetch --tags
	git switch -d --discard-changes $INDI_COMMIT
else
	git pull origin
fi
[ ! -d ../build-indi ] && { cmake -G Ninja -B ../build-indi ../indi -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release || { echo "INDI configuration failed"; exit 1; } }
cd ../build-indi
ninja -j $JOBS || { echo "INDI compilation failed"; exit 1; }
sudo ninja install || { echo "INDI installation failed"; exit 1; }

#cd "$ROOTDIR"
#[ ! -d "indi-3rdparty" ] && { git clone --depth 1 https://github.com/indilib/indi-3rdparty.git || { echo "Failed to clone indi 3rdparty"; exit 1; } }
#cd indi-3rdparty
#if [ -n $INDI_3RD_COMMIT ] && [ $INDI_3RD_COMMIT != "master" ]; then
#	git fetch origin
#    git fetch --tags
#	git switch -d --discard-changes $INDI_3RD_COMMIT
#else
#	git pull origin
#fi
#[ ! -d ../build-indi-lib ] && { cmake -B ../build-indi-lib ../indi-3rdparty -DCMAKE_INSTALL_PREFIX=/usr -DBUILD_LIBS=1 -DCMAKE_BUILD_TYPE=Release || { echo "INDI lib configuration failed"; exit 1; } }
#cd ../build-indi-lib
#make -j $JOBS || { echo "INDI lib compilation failed"; exit 1; }
#sudo make install || { echo "INDI lib installation failed"; exit 1; }

#[ ! -d ../build-indi-3rdparty ] && { cmake -B ../build-indi-3rdparty ../indi-3rdparty -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release || { echo "INDI lib configuration failed"; exit 1; } }
#cd ../build-indi-3rdparty
#make -j $JOBS || { echo "INDI 3rd-party compilation failed"; exit 1; }
#sudo make install || { echo "INDI lib installation failed"; exit 1; }

cd "$ROOTDIR"
[ ! -d "stellarsolver" ] && { git clone --depth 1 https://github.com/rlancaste/stellarsolver.git || { echo "Failed to clone stellarsolver"; exit 1; } }
cd stellarsolver
if [ -n $STELLAR_COMMIT ] && [ $STELLAR_COMMIT != "master" ]; then
	git fetch origin
    git fetch --tags
	git switch -d --discard-changes $STELLAR_COMMIT
else
	git pull origin
fi
[ ! -d ../build-stellarsolver ] && { cmake -G Ninja -B ../build-stellarsolver ../stellarsolver -DCMAKE_BUILD_TYPE=Release || { echo "Stellarsolfer configuration failed"; exit 1; } }
cd ../build-stellarsolver
ninja -j $JOBS || { echo "Stellarsolver compilation failed"; exit 1; }
sudo ninja install || { echo "Stellarsolver installation failed"; exit 1; }

cd "$ROOTDIR"
[ ! -d "kstars" ] && { git clone --depth 1 https://invent.kde.org/education/kstars.git || { echo "Failed to clone KStars"; exit 1; } }
cd kstars
if [ -n $KSTARS_COMMIT ] && [ $KSTARS_COMMIT != "master" ]; then
	git fetch origin
    git fetch --tags
	git switch -d --discard-changes $KSTARS_COMMIT
else
	git pull origin
fi
[ ! -d ../build-kstars ] && { cmake -G Ninja -B ../build-kstars -DBUILD_TESTING=OFF -DBUILD_DOC=OFF ../kstars -DCMAKE_BUILD_TYPE=Release || { echo "KStars configuration failed"; exit 1; } }
cd ../build-kstars
ninja -j $JOBS || { echo "KStars compilation failed"; exit 1; }
sudo ninja install || { echo "KStars installation failed"; exit 1; }

sudo ldconfig



[ "$1" != "phd2" ] && exit

cd "$ROOTDIR"
[ ! -d "phd2" ] && { git clone https://github.com/OpenPHDGuiding/phd2.git || { echo "Failed to clone PHD2"; exit 1; } }
cd phd2
if [ -n $PHD2_COMMIT ] && [ $PHD2_COMMIT != "master" ]; then
	git fetch origin
    git fetch --tags
	git switch -d --discard-changes $PHD2_COMMIT
else
	git pull origin
fi
[ ! -d ../build-phd2 ] && cmake -G Ninja -B ../build-phd2 -DCMAKE_BUILD_TYPE=Release || { echo "PHD2 configuration failed"; exit 1; }
cd ../build-phd2
ninja -j $JOBS || { echo "PHD2 compilation failed"; exit 1; }
sudo ninja install

