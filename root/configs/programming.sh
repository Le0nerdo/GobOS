echo "### Starting programming configuration."

read -rp "Install programming software [y/n]? " check

if [[ $check != "y" ]]; then
	echo "### Aborting programming configuration"
	exit 1
fi

pacman -S --noconfig neovim code

echo "### Finished programming configuration."

