#!/bin/sh

set -eux

ARCH=$(uname -m)
BINS_SOURCE="$PWD"/scrcpy/release/work/build-linux-"$ARCH"/dist
UDEV="https://raw.githubusercontent.com/M0Rf30/android-udev-rules/refs/heads/main/51-android.rules"

export ARCH
export ADD_HOOKS="self-updater.bg.hook:udev-installer.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export DEPLOY_OPENGL=1
export DEPLOY_PIPEWIRE=1
export OUTPATH=./dist
export ICON="$BINS_SOURCE"/icon.png
export MAIN_BIN=scrcpy

# Deploy dependencies
quick-sharun "$BINS_SOURCE"/*
cp -v /usr/share/scrcpy/scrcpy-server  ./AppDir/bin # get server binary
cp -v "$BINS_SOURCE"/scrcpy.1          ./AppDir/bin # man page?
sed -i -e 's|Exec=.*|Exec=scrcpy|g'    ./AppDir/*.desktop
echo 'SCRCPY_SERVER_PATH=${SHARUN_DIR}/bin/scrcpy-server' >> ./AppDir/.env
echo 'SCRCPY_ICON_PATH=${SHARUN_DIR}/icon.png'            >> ./AppDir/.env

# Add udev rules
mkdir -p ./AppDir/etc/udev/rules.d
wget --retry-connrefused --tries=30 "$UDEV" -O ./AppDir/etc/udev/rules.d/51-android.rules
# We also need to be added to a group after installing udev rules
sed -i '/cp -v/a	 groupadd -f adbusers; usermod -a -G adbusers $(logname)' ./AppDir/bin/udev-installer.hook

# Turn AppDir into AppImage
VERSION="$(./AppDir/AppRun --version | awk '{print $2; exit}')"
[ -n "$VERSION" ] && export VERSION
quick-sharun --make-appimage
