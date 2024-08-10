# Deleting possible old build
rm -rf ./out/

# Moving files to temp
mkdir ./temp
cp -r /usr/share/archiso/configs/releng/* ./temp/
cp -r ./root/* ./temp/airootfs/root/

# Configuring
sed -i '/iso_name="archlinux"/c\iso_name="GobOS"' ./temp/profiledef.sh
sed -i 's,https://archlinux.org,https://github.com/Le0nerdo/GobOS,' ./temp/profiledef.sh
sed -i 's/ARCH/GobOS/' ./temp/profiledef.sh
sed -i 's/Arch Linux/GobOS/' ./temp/profiledef.sh

sed -i '$i\ \ ["/root/install.sh"]="0:0:755"' ./temp/profiledef.sh
sed -i '$i\ \ ["/root/configs/main.sh"]="0:0:755"' ./temp/profiledef.sh


# Building iso
mkarchiso -v ./temp/

# Removing things
rm -r ./temp/
rm -r ./work/
