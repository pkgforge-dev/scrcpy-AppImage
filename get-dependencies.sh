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

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano

echo "Building mostly static scrcpy..."
echo "---------------------------------------------------------------"
GRON="https://raw.githubusercontent.com/xonixx/gron.awk/refs/heads/main/gron.awk"
wget --retry-connrefused --tries=30 "$GRON" -O ./gron.awk
chmod +x ./gron.awk

LATEST_TAG=$(wget "https://api.github.com/repos/Genymobile/scrcpy/tags" -O - \
                | ./gron.awk | awk -F'=|"' '/name/ {print $3; exit}')

git clone --branch "$LATEST_TAG" --single-branch "https://github.com/Genymobile/scrcpy.git" ./scrcpy
cd ./scrcpy
# path needs to be updated to incldue perl
export PATH="$PATH:/usr/bin/core_perl"
# do the thing
./release/build_linux.sh "$ARCH"

echo "All done!"
echo "---------------------------------------------------------------"
