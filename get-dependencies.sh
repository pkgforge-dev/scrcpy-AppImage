#!/bin/sh

set -eux

ARCH="$(uname -m)"

case "$ARCH" in
	'x86_64')  PKG_TYPE='x86_64.pkg.tar.zst';;
	'aarch64') PKG_TYPE='aarch64.pkg.tar.xz';;
	''|*) echo "Unknown arch: $ARCH"; exit 1;;
esac

echo "Installing build dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
  	android-tools     \
	base-devel        \
	curl              \
	ffmpeg            \
	fontconfig        \
	freetype2         \
	git               \
	libusb            \
	libxcb            \
	libxcursor        \
	libxi             \
	libxkbcommon      \
	libxkbcommon-x11  \
	libxrandr         \
	libxtst           \
	mesa              \
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

LLVM_URL="https://github.com/pkgforge-dev/llvm-libs-debloated/releases/download/continuous/llvm-libs-nano-$PKG_TYPE"
MESA_URL="https://github.com/pkgforge-dev/llvm-libs-debloated/releases/download/continuous/mesa-mini-$PKG_TYPE"
LIBXML_URL="https://github.com/pkgforge-dev/llvm-libs-debloated/releases/download/continuous/libxml2-iculess-$PKG_TYPE"
FFMPEG_URL="https://github.com/pkgforge-dev/llvm-libs-debloated/releases/download/continuous/ffmpeg-mini-$PKG_TYPE"
OPUS_URL="https://github.com/pkgforge-dev/llvm-libs-debloated/releases/download/continuous/opus-nano-$PKG_TYPE"

wget --retry-connrefused --tries=30 "$LLVM_URL"   -O  ./llvm-libs.pkg.tar.zst
wget --retry-connrefused --tries=30 "$MESA_URL"   -O  ./mesa.pkg.tar.zst
wget --retry-connrefused --tries=30 "$LIBXML_URL" -O  ./libxml2.pkg.tar.zst
#wget --retry-connrefused --tries=30 "$FFMPEG_URL" -O  ./ffmpeg-mini.pkg.tar.zst
wget --retry-connrefused --tries=30 "$OPUS_URL"   -O  ./opus.pkg.tar.zst

pacman -U --noconfirm ./*.pkg.tar.zst
rm -f ./*.pkg.tar.zst

echo "Building mostly static scrcpy"
git clone "https://github.com/Genymobile/scrcpy.git" ./scrcpy
cd ./scrcpy
# path needs to be updated to incldue perl
export PATH="$PATH:/usr/bin/core_perl"

# do the thing
./release/build_linux.sh "$ARCH"

echo "All done!"
echo "---------------------------------------------------------------"
