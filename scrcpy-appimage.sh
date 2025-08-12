#!/bin/sh

set -eux

ARCH="$(uname -m)"
URUNTIME="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/uruntime2appimage.sh"
SHARUN="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/quick-sharun.sh"
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
cp -v "$BINS_SOURCE"/scrcpy.1          ./AppDir/bin
sed -i -e 's|Exec=.*|Exec=scrcpy|g'    ./AppDir/*.desktop




export VERSION="$(./AppDir/AppRun --version | awk '{print $2; exit}')"
[ -n "$VERSION" ] && echo "$VERSION" > ~/version

# MAKE APPIMAGE WITH URUNTIME
wget --retry-connrefused --tries=30 "$URUNTIME"      -O  ./uruntime
wget --retry-connrefused --tries=30 "$URUNTIME_LITE" -O  ./uruntime-lite
chmod +x ./uruntime*

# Add udpate info to runtime
echo "Adding update information \"$UPINFO\" to runtime..."
./uruntime-lite --appimage-addupdinfo "$UPINFO"

echo "Generating AppImage..."
./uruntime \
	--appimage-mkdwarfs -f               \
	--set-owner 0 --set-group 0          \
	--no-history --no-create-timestamp   \
	--compression zstd:level=22 -S26 -B8 \
	--header uruntime-lite               \
	-i ./AppDir                          \
	-o ./scrcpy-"$VERSION"-anylinux-"$ARCH".AppImage

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

echo "All Done!"
