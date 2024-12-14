# TODO: This is probably NVIDIA specific, and there is likely a change to wayland.
echo "### Starting to install visual software"

# X11
pacman -S --noconfirm xorg-server xorg-xinit

# KDE Plasma
pacman -S --noconfirm plasma ttf-dejavu ttf-liberation

# This seems to not work
echo "export DESKTOP_SESSION=plasma" > .xinitrc
echo "exec startplasma-x11" >> .xinitrc

echo "### Finished to install visual software"
