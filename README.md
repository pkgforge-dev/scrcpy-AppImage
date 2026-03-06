<div align="center">

# scrcpy-AppImage 🐧

[![GitHub Downloads](https://img.shields.io/github/downloads/pkgforge-dev/scrcpy-AppImage/total?logo=github&label=GitHub%20Downloads)](https://github.com/pkgforge-dev/scrcpy-AppImage/releases/latest)
[![CI Build Status](https://github.com/pkgforge-dev/scrcpy-AppImage/actions/workflows/appimage.yml/badge.svg)](https://github.com/pkgforge-dev/scrcpy-AppImage/releases/latest)
[![Latest Stable Release](https://img.shields.io/github/v/release/pkgforge-dev/scrcpy-AppImage)](https://github.com/pkgforge-dev/scrcpy-AppImage/releases/latest)

<p align="center">
  <img src="https://raw.githubusercontent.com/Genymobile/scrcpy/3fcc177da5b6b4514d0e8e8d90d7d58d6731eac9/app/data/icon.svg" width="128" />
</p>


| Latest Stable Release | Upstream URL |
| :---: | :---: |
| [Click here](https://github.com/pkgforge-dev/scrcpy-AppImage/releases/latest) | [Click here](https://github.com/Genymobile/scrcpy) |

</div>

---

AppImage made using [sharun](https://github.com/VHSgunzo/sharun) and its wrapper [quick-sharun](https://github.com/pkgforge-dev/Anylinux-AppImages/blob/main/useful-tools/quick-sharun.sh), which makes it extremely easy to turn any binary into a portable package reliably without using containers or similar tricks. 

**This AppImage bundles everything and it should work on any Linux distro, including old and musl-based ones.**

It is possible that this appimage may fail to work with appimagelauncher, I recommend these alternatives instead: 

* [AM](https://github.com/ivan-hc/AM) `am -i scrcpy` or `appman -i scrcpy`

* [dbin](https://github.com/xplshn/dbin) `dbin install scrcpy.appimage`

* [soar](https://github.com/pkgforge/soar) `soar install scrcpy`

This AppImage doesn't require FUSE to run at all, thanks to the [uruntime](https://github.com/VHSgunzo/uruntime).

This AppImage is also supplied with a self-updater by default, so any updates to this application won't be missed, you will be prompted for permission to check for updates and if agreed you will then be notified when a new update is available.

Self-updater is disabled by default if AppImage managers like [am](https://github.com/ivan-hc/AM), [soar](https://github.com/pkgforge/soar) or [dbin](https://github.com/xplshn/dbin) exist, which manage AppImage updates.

<details>
  <summary><b><i>raison d'être</i></b></summary>
    <img src="https://github.com/user-attachments/assets/d40067a6-37d2-4784-927c-2c7f7cc6104b" alt="Inspiration Image">
  </a>
</details>

---

More at: [AnyLinux-AppImages](https://pkgforge-dev.github.io/Anylinux-AppImages/)
