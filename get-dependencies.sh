#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
  	android-tools     \
	ffmpeg            \
	fontconfig        \
	freetype2         \
	libusb            \
	meson             \
	nasm              \
	ninja             \
	patch             \
	perl              \
	pipewire-audio    \
	pulseaudio        \
	pulseaudio-alsa   \
	scrcpy            \
	sdl2              \
	unzip             \
	wget              \
	xorg-server-xvfb  \
	zsync

# path needs to be updated to incldue perl
export PATH="$PATH:/usr/bin/core_perl"

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano

echo "Building mostly static scrcpy..."
echo "---------------------------------------------------------------"
git clone "https://github.com/Genymobile/scrcpy.git" ./scrcpy
cd ./scrcpy
git fetch --tags origin
TAG=$(git tag --sort=-v:refname | grep -vi 'rc\|alpha' | head -1)
git checkout "$TAG"
echo "$TAG" > ~/version
# do the thing
./release/build_linux.sh "$ARCH"

echo "All done!"
echo "---------------------------------------------------------------"
