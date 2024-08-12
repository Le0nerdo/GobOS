# WARNING THIS DISTRIBUTION IS CURRENTLY WORK IN PROGRESS AND MOST LIKELY LEADS TO FAULTY INSTALLATIONS

# GobOS
> An Arch distribution/install script for programming and playing video games. The build script builds an iso file based on releng in [archiso](https://wiki.archlinux.org/title/Archiso) that contains the install scripts.

Requirements to build
- [archiso](https://wiki.archlinux.org/title/Archiso)

# Put iso to usb drive
cp ./out/archlinux-version-x86_64.iso /dev/disk/by-id/usb-My_flash_drive

# Usage
run `./install.sh` after booting into live enviroment.

# Limitations
- only supports NVIDIA GPU
- only supports AMD and Intel CPU:s

# TODO
- AMD GPU support (can take some time, now only support new nvidia gpus)

- install.sh
  - Select keymap and save it in an info file in configs.
  - https://wiki.archlinux.org/title/Installation_guide#Verify_the_boot_mode
  - https://wiki.archlinux.org/title/Installation_guide#Select_the_mirrors

- configs/main
  - selecting keymap

- configs/visual
  - test wayland
