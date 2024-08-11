RED='\033[0;31m'
NC='\033[0m'

echo "### Starting configuration."

echo "Select time zone region:"

break_outer=false
while :
do
	while :
	do
		echo ""
		regions=`ls -dl /usr/share/zoneinfo/*/ | sed 's,.*/zoneinfo/,,' | grep '^[A-Z]' | sed 's/.$//'`
		index=-1
		while read -r region_line;
		do
			index=$(( $index + 1 ))
			echo "    $index) $region_line"
		done <<< "$regions"
		echo ""
		read -r -p "Select number from 0 to $index: " selected_index

		if (( selected_index >= 0 && selected_index <= index )); then
			break
		fi
		echo -e "${RED}Invalid Index${NC}"
	done

	selected_index=$(( $selected_index + 1 ))
	REGION=`sed "${selected_index}q;d" <<< "$regions"`

	while :
	do
		echo ""
		echo "Select time zone city from below:"
		echo ""
		ls /usr/share/zoneinfo/$REGION/
		echo ""
		read -r -p "Type name of city (empty to reselect region): " selected_city

		if [[ "$selected_city" == "" ]]; then
			break
		fi

		found=`ls /usr/share/zoneinfo/$REGION/ | grep -xi "$selected_city" | wc -l`
		if (( found == 1 )); then
			CITY=`ls /usr/share/zoneinfo/$REGION/ | grep -xi "$selected_city"`
			break_outer=true
			break
		fi

		echo -e "${RED}Did not find city, let's try again${NC}"
	done

	if [ "$break_outer" = true ] ; then
		break
	fi
done

echo "Setting language, timezone and keymap."
ln -sf /usr/share/zoneinfo/"$REGION"/"$CITY"/ /etc/localtime
hwclock --systohc

echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# TODO: Need to actually set this.
echo "KEYMAP=fi" > /etc/vconsole.conf

echo "Enabling multilib."
echo "[multilib]" >> /etc/pacman.conf
echo "Include = /etc/pacman.d/mirrorlist" >> /etc/pacman.conf
pacman -Sy

run_conf() {
	chmod +x "./configs/$1.sh"
	"./configs$1.sh"
}

run_conf hardware
run_conf user
run_conf visual

# Install basic software
# -vim, konsole, bashtop, firefox, discord, git
#
# Gaming stuff
#
# Programming stuff

rm -r ../configs/
