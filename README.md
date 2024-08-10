# WARNING THIS DISTRIBUTION IS CURRENTLY WORK IN PROGRESS AND LEADS TO FAULTY INSTALLATIONS

# GobOS
> An Arch distribution/install script for programming and playing video games. The build script builds an iso file based on releng in [archiso](https://wiki.archlinux.org/title/Archiso) that contains the install scripts.

Requirements to build
- [archiso](https://wiki.archlinux.org/title/Archiso)

# Put iso to usb drive
cp ./out/archlinux-version-x86_64.iso /dev/disk/by-id/usb-My_flash_drive

# Usage
run `./install.sh` after booting into live enviroment.

# TODO
- install.sh
  - https://wiki.archlinux.org/title/Installation_guide#Verify_the_boot_mode
  - https://wiki.archlinux.org/title/Installation_guide#Select_the_mirrors

- configs
  - Hardware confi
  - User Config
  - Game config
  - Programming config
