#!/bin/sh

set -eux

ARCH="$(uname -m)"
URUNTIME="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/uruntime2appimage.sh"
SHARUN="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/quick-sharun.sh"
UDEV="https://raw.githubusercontent.com/M0Rf30/android-udev-rules/refs/heads/main/51-android.rules"
BINS_SOURCE="$PWD"/scrcpy/release/work/build-linux-"$ARCH"/dist

export ADD_HOOKS="self-updater.bg.hook:udev-installer.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export DEPLOY_OPENGL=1
export DEPLOY_PIPEWIRE=1
export ICON="$BINS_SOURCE"/icon.png
export DESKTOP="https://raw.githubusercontent.com/Genymobile/scrcpy/refs/heads/master/app/data/scrcpy.desktop"

# ADD LIBRARIES
wget --retry-connrefused --tries=30 "$SHARUN" -O ./quick-sharun
chmod +x ./quick-sharun
./quick-sharun "$BINS_SOURCE"/*

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

# MAKE APPIMAGE WITH URUNTIME
export VERSION="$(./AppDir/AppRun --version | awk '{print $2; exit}')"
export OUTNAME=scrcpy-"$VERSION"-anylinux-"$ARCH".AppImage
[ -n "$VERSION" ] && echo "$VERSION" > ~/version

wget --retry-connrefused --tries=30 "$URUNTIME" -O ./uruntime2appimage
chmod +x ./uruntime2appimage
./uruntime2appimage


# make appbundle
UPINFO="$(echo "$UPINFO" | sed 's#.AppImage.zsync#*.AppBundle.zsync#g')"
wget --retry-connrefused --tries=30 \
	"https://github.com/xplshn/pelf/releases/latest/download/pelf_$ARCH" -O ./pelf
chmod +x ./pelf
echo "Generating [dwfs]AppBundle..."
./pelf \
	--compression "-C zstd:level=22 -S26 -B8" \
	--appbundle-id="scrcpy-$VERSION"          \
	--appimage-compat                         \
	--add-updinfo "$UPINFO"                   \
	--add-appdir ./AppDir                     \
	--output-to ./scrcpy-"$VERSION"-anylinux-"$ARCH".dwfs.AppBundle
zsyncmake ./*.AppBundle -u ./*.AppBundle

mkdir -p ./dist
mv -v ./*.AppImage*  ./dist
mv -v ./*.AppBundle* ./dist
mv -v ~/version      ./dist

echo "All Done!"
