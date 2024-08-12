echo "### Starting gaming configuration."

read -rp "Install gaming sofware [y/n]? " check

if [[ $check != "y" ]]; then
	echo "### Aborting gaming configuration."
	exit 1
fi

pacman -S --noconfig steam

echo "### Finished gaming configuration."

