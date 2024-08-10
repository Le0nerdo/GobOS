echo "### Starting hardware configuration."

systemctl enable fstrim.timer

echo "### Starting network configuration..."
echo ""
read -r -p "Give host name: " HOST_NAME
echo ""
echo "$HOST_NAME" > /etc/hostname
pacman -S --noconfirm dhcpcd networkmanager
systemctl enable dhcpcd.service
systemctl enable NetworkManager.service

echo "### Completed network configuration."

echo "### Starting boot loader configuration..."

intel=`grep "model name" /proc/cpuinfo  | grep -i "intel" | wc -l`
amd=`grep "model name" /proc/cpuinfo  | grep -i "amd" | wc -l`

bootctl --graceful install

if (( intel > 0 )) ; then
	pacman -S --noconfirm intel-ucode
fi

if (( amd > 0 )) ; then
	pacman -S --noconfirm amd-ucode
fi

echo "title GobOS" > /boot/loader/entries/arch.conf
echo "linux /vmlinuz-linux-zen" >> /boot/loader/entries/arch.conf

if (( amd > 0 )) ; then
	echo "initrd /amd-ucode.img" >> /boot/loader/entries/arch.conf
else 
	echo "initrd /intel-ucode.img" >> /boot/loader/entries/arch.conf
fi

echo "initrd /initramfs-linux-zen.img" >> /boot/loader/entries/arch.conf

PART3=`grep "PARTITION3=" ./configs/VARIABLES.txt | sed 's,PARTITION3=,,'`
echo "options root=PARTUUID=$(blkid -s PARTUUID -o value "$PART3") rw" >> /boot/loader/entries/arch.conf

echo "### Completed boot loader configuration."

echo "### GPU configuration."

nvidia=`lspci -k | grep -A 2 -E "(VGA|3D)" | grep "NVIDIA" | wc -l`
if (( nvidia > 0 )) ; then
	echo "Detected nvidia GPU, installing drivers..."

	pacman -S --noconfirm linux-zen-headers nvidia-dkms nvidia-utils opencl-nvidia \
	libglvnd lib32-nvidia-utils lib32-opencl-nvidia lib32-libglvnd nvidia-settings

	# Set nvidia_drm.modeset=1 kernel parameter
	sed -i '$s/$/ nvidia-drm.modeset=1/' /boot/loader/entries/arch.conf

	# add modules for early loading
	sed -i 's/MODULES=(/&nvidia nvidia_modeset nvidia_uvm nvidia_drm/' /etc/mkinitcpio.conf

	# Automatic update to initramfs after NVIDIA driver update
	mkdir /etc/pacman.d/hooks

	echo "[Trigger]" > /etc/pacman.d/hooks/nvidia.hook
	echo "Operation=Install" >> /etc/pacman.d/hooks/nvidia.hook
	echo "Operation=Upgrade" >> /etc/pacman.d/hooks/nvidia.hook
	echo "Operation=Remove" >> /etc/pacman.d/hooks/nvidia.hook
	echo "Type=Package" >> /etc/pacman.d/hooks/nvidia.hook
	echo "Target=nvidia-dkms" >> /etc/pacman.d/hooks/nvidia.hook

	echo "[Action]" >> /etc/pacman.d/hooks/nvidia.hook
	echo "Depends=mkinitcpio" >> /etc/pacman.d/hooks/nvidia.hook
	echo "When=PostTransaction" >> /etc/pacman.d/hooks/nvidia.hook
	echo "Exec=/usr/bin/mkinitcpio -P" >> /etc/pacman.d/hooks/nvidia.hook
fi

echo "### Completed GPU configuration."

# misc stuff
pacman -S -noconfirm pipewire lib32-pipewire wireplumber bluez bluez-utils
systemctl enable bluetooth.service

echo "### Completed hardware configuration"

