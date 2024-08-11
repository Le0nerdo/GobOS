echo "### Starting user configuration."

while :
do
	echo ""
	read -srp "Type root password: " root1
	echo ""
	read -srp "Type root password again: " root2
	echo ""
	echo ""

	if [[ $root1 == $root2 ]]; then
		ROOT_PASSWORD="$root1"
		break
	fi

	echo "Passwords do not match. Try again."
done


while :
do
	read -rp "Give user name: " user_name
	read -rp "Select user name $user_name [y/n]? " ye
	echo ""

	if [[ $ye == "y" ]]; then
		USER_NAME="$user_name"
		break
	fi

	echo "Ok, let's try again."
	echo ""
done

while :
do
	read -srp "Type user password: " user_pw1
	echo ""
	read -srp "Type user password again: " user_pw2
	echo ""
	echo ""

	if [[ $user_pw1 == $user_pw2 ]]; then
		USER_PASSWORD="$user_pw1"
		break
	fi

	echo "Passwords do not match. Try again."
	echo ""
done

echo y | pacman -S sudo
echo -e ""$ROOT_PASSWORD"\n"$ROOT_PASSWORD"" | passwd
useradd -m -g users -G wheel,storage,power,lp -s /bin/bash $USER_NAME
echo -e ""$USER_PASSWORD"\n"$USER_PASSWORD"" | passwd $USER_NAME
echo "%wheel ALL=(ALL) ALL" | EDITOR="tee -a" visudo
echo "Defaults rootpw" | EDITOR="tee -a" visudo

echo "### Completed user configuration."
