# n_flasher
## Description
__n_flasher__ is a powerfull application for Nokia phones flashing written by Dlang and Gtk+ (GtkD)

![alt text](https://raw.githubusercontent.com/KonstantIMP/n_flasher/main/.readme/app_screenshot.png "n_flasher screenshot")
## Features
* Fully linux and Windows support
* ADB tools path set
* ROM Path set
* ROM integrity check
* VBmeta flashing support
* A and B slot flashing
* Full and SVB flashing modes
* Smouth UI
* Extended loging

## Supported devices
* Nokia 7.1 (CTL_sprout)
* Other Nokia devices, but I can't check, because I don't have them ... If you want to help expand the list of supported devices, please contact me.

## How can I use it?

1. Download or build latest n_flasher version
2. Download and install android tools (adb and fastboot)
3. Download ROM and unarchive it
4. Start the application
5. Set android tools path
6. Set ROM path
7. Connect your phone to computer and enable USB debuging and file transfer
8. Set options you need
9. Press 'Flash' or 'SVB flash'

### Building
``` bash
# 1. Download android tools
sudo pacman -S android-tools android-udev
# 2. Download building dependencies
sudo pacman -S dlang meson base-devel
dub fetch gtk-d
dub fetch djtext
dub build --compiler=ldc2 gtk-d
dub build --compiler=ldc2 djtext
# 3. Clone this repo
git clone https://github.com/KonstantIMP/n_flasher.git
# 4. Build it
cd n_flasher
meson builddir
ninja -C builddir
# 5. Run the n_flasher
./builddir/n_flasher
```

#### Note

For Windows platforms you can just download latest release and run runline.exe

## Additional info

![GitHub release (latest by date)](https://img.shields.io/github/v/release/KonstantIMP/n_flasher?style=flat-square) ![GitHub](https://img.shields.io/github/license/KonstantIMP/n_flasher?style=flat-square)