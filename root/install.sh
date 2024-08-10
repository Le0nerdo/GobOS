#!/bin/sh

# set time
timedatectl set-ntp true

RED='\033[0;31m'
NC='\033[0m'

disks=`fdisk -l 2> /dev/null | pcregrep -M "Disk \/dev\/.*\nDisk model:.*"` 2> /dev/null

while :
do
	echo ""
	echo "Select disk for installation."
	echo -e "${RED}WARNING: This will delete all content on the disk!${NC}"
	echo ""

	index=-1
	while read -r disk_data; do
		index=$(( $index + 1))
		read -r disk_model

		clean_model="${disk_model/"Disk model: "/""}"
		clean_size=`grep -o ': .*B' <<< "$disk_data"`
		clean_address=`grep -o '/dev.*:' <<< "$disk_data"`
		clean_address=${clean_address::-1}

		echo "    $index) Model: $clean_model, size$clean_size, address: $clean_address"
	done <<< "$disks"
	echo ""

	read -n 1 -p "Select number from 0 to $index: " selected_index
	echo ""


	if ((selected_index >= 0 && selected_index <= index)); then
		break
	fi

	echo "Invalid Index!"
done

echo "You selected the disk with the following information:"
echo ""

temp_index=$((selected_index * 2 + 1))
temp_line=`sed "${temp_index}q;d" <<< "$disks"`
DRIVE_NAME=`grep -o '/dev.*:' <<< "$temp_line"`
DRIVE_NAME=${DRIVE_NAME::-1}
	
fdisk -l "$address"

echo ""
echo -e "${RED}Are you sure that you want to delete the contents of the above disk?${NC}"

read -r -p "Type 'DELETE' and press enter to agree: " delete_string

if [[ "$delete_string" != 'DELETE' ]]; then
	echo "Exiting script!"
	exit 1
fi

echo ""
echo -e "${RED}WARNING THIS WILL DELETE ALL YOUR DATA ON THE SELECTED DISK${NC}"
read -r -p "Type 'I AGREE' and press enter to agree: " delete_string

if [[ "$delete_string" != 'I AGREE' ]]; then 
	echo "Exiting script!"
	exit 1
fi


echo "### Clearing drive..."
sgdisk -Z /env/"$DRIVE_NAME"


echo "### Partitioning drive..."
drive_bytes=`fdisk -l "$DRIVE_NAME" | sed '1!d' | grep -o ', .* bytes' | grep -o -E '[0-9]*'`
if (( drive_bytes >= 1100000000000 ))
then
	ROOT_SIZE=35G
else 
	ROOT_SIZE=60G
fi

sgdisk -n 1:0:+1024M -c 1:boot -t 1:ef00 "$DRIVE_NAME"
sgdisk -n 2:0:+16G -c 2:boot -t 2:8200 "$DRIVE_NAME"
sgdisk -n 3:0:+"$ROOT_SIZE" -c 3:boot -t 3:8300 "$DRIVE_NAME"
sgdisk -n 4:0:+0 -c 4:boot -t 4:8300 "$DRIVE_NAME"

echo "### Formatting drive..."

partitions=`lsblk -o name "$DRIVE_NAME" | sed 1,2d | cut -c 7-`

if (( `wc -l <<< "$partitions"` != 4 )); then
	echo "Partitionin somehow failed :("
	echo "Exiting"
	exit 1
fi

partition1="/dev/`sed 1!d <<< "$partitions"`"
partition2="/dev/`sed 2!d <<< "$partitions"`"
partition3="/dev/`sed 3!d <<< "$partitions"`"
partition4="/dev/`sed 4!d <<< "$partitions"`"

mkfs.fat -F32 "$partition1"
mkswap "$partition2"
swapon "$partition2"
mkfs.ext4 "$partition3"
mkfs.ext4 "$partition4"

echo "### Mounting drive..."
mount "$partition3" /mnt
mkdir /mnt/booti
mkdir /mnt/home
mount "$partition1" /mnt/boot
mount "$partition4" /mnt/home

echo "### Completed preparing drive!"

echo "### Installing linux..."
pacstrap /mnt base linux-zen linux-firmware

# configure fstab
genfstab -U /mnt >> /mnt/etc/fstab

echo "### Moving into chroot and running configs."
cp -r ./configs/ /mnt/destination/

# Can run `arch-chroot /mnt` to manually edit things
arch-chroot /mnt ./configs/main.sh

echo "### Installation complete."
echo "### Now you are using arch by the way."
echo "### Reboot with 'reboot' and take out the installation medium."
