#!/bin/sh

set -ex

ARCH="$(uname -m)"
URUNTIME="https://github.com/VHSgunzo/uruntime/releases/latest/download/uruntime-appimage-dwarfs-$ARCH"
URUNTIME_LITE="https://github.com/VHSgunzo/uruntime/releases/latest/download/uruntime-appimage-dwarfs-lite-$ARCH"
SHARUN="https://github.com/VHSgunzo/sharun/releases/latest/download/sharun-$ARCH-aio"
UPINFO="gh-releases-zsync|$(echo "$GITHUB_REPOSITORY" | tr '/' '|')|latest|*$ARCH.AppImage.zsync"

# Prepare AppDir
mv -v ./scrcpy/release/work/build-linux-"$ARCH"/dist ./AppDir

mkdir -p ./AppDir/share ./AppDir/shared/bin ./AppDir/bin && (
	cd ./AppDir
	mv -v ./scrcpy        ./shared/bin
	mv -v ./adb           ./shared/bin
	mv -v ./scrcpy-server ./share/scrcpy
	mv -v ./scrcpy.1      ./bin

	cp -v ./icon.png ./.DirIcon
	mv -v ./icon.png ./bin
	
	# desktop, icon, app data files
	wget --retry-connrefused --tries=30 "$DESKTOP" -O ./scrcpy.desktop
	sed -i -e 's|Exec=.*|Exec=scrcpy|g' ./scrcpy.desktop

	# ADD LIBRARIES
	wget --retry-connrefused --tries=30 "$SHARUN" -O ./sharun-aio
	chmod +x ./sharun-aio
	xvfb-run -a -- \
		./sharun-aio l -p -v -e -s -k \
		./shared/bin/*                \
		/usr/lib/libGLX*              \
		/usr/lib/libEGL*              \
		/usr/lib/dri/*                \
		/usr/lib/gbm/*                \
		/usr/lib/pipewire-*/*         \
		/usr/lib/spa-*/*/*            \
		/usr/lib/pulseaudio/*         \
		/usr/lib/gconv/*
	rm -f ./sharun-aio

	# Prepare sharun
	chmod +x ./AppRun
	./sharun -g

	# Add udev rules installer
	git clone "https://github.com/M0Rf30/android-udev-rules.git" ./udev-installer
	rm -rf ./udev-installer/.github ./udev-installer/.git
)

VERSION="$(./AppDir/AppRun --version | awk '{print $2; exit}')"
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

zsyncmake ./*.AppImage -u  ./*.AppImage
zsyncmake ./*.AppBundle -u ./*.AppBundle

mkdir -p ./dist
mv -v ./*.AppImage*  ./dist
mv -v ./*.AppBundle* ./dist

echo "All Done!"
