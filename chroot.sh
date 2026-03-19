#!/bin/bash

#time
echo -e "\nSetting time..."
ln -sf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime
hwclock --systohc
timedatectl

sleep 1

# localization
echo "Setting localization..."
echo -e "About to show all valid locales. Once you have picked a locale press Q to enter the locale you wish to use."
read -n 1 -s -p "Press any key to continue..."
localectl list-locales
while true; do
	read -p "Enter the locale you want (e.g. en_GB.UTF-8, en_US.UTF-8): " LOCALIZATION

	# check if locale exists in locale.gen
	if grep -q "^#\?${LOCALIZATION}\b" /etc/locale.gen; then
    	echo "Locale valid: ${LOCALIZATION}"
    	sed -i "s/^#\?\(${LOCALIZATION}\b.*\)/\1/" /etc/locale.gen
		break
	else
    	echo "Invalid locale: ${LOCALIZATION}"
	fi

done

echo "Setting system default locale..."
echo "LANG=${LOCALIZATION}" >/etc/locale.conf

echo "Generating locale..."
locale-gen

#keymap
echo "Setting keymap..."
echo "KEYMAP=${KEYMAP}" >/etc/vconsole.conf

# hostname
while true; do
	read -p "Enter the hostname you want (e.g. archinator): " HOSTNAME

	# no empty input
	if [[ -z "$HOSTNAME" ]]; then
		echo "Hostname cannot be empty."
		continue
	fi

	# validate hostname (1–63 chars, lowercase, digits, hyphens, cannot start or end with -)
	if [[ "$HOSTNAME" =~ ^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?$ ]]; then
		echo "Hostname accepted: $HOSTNAME"
		break
	else
		echo "Invalid hostname."
		echo "Rules:"
		echo "- 1 to 63 characters"
		echo "- lowercase a–z, digits 0–9, and hyphens"
		echo "- cannot start or end with a hyphen"
	fi
done

# hosts

echo "hosts stuff"
cat <<EOF >/etc/hosts
127.0.0.1   localhost
::1         localhost
127.0.1.1   ${HOSTNAME}.localdomain ${HOSTNAME}
EOF

echo "$HOSTNAME" >/etc/hostname
echo "Hostname ${HOSTNAME} has been set."

#luks

if [[ "$luks_encryption" =~ ^[Yy]$ ]]; then
    echo "Enabling LUKS support in initramfs..."
    sed -i 's/\(block\)/\1 keyboard encrypt/' /etc/mkinitcpio.conf
fi

# initramfs

mkinitcpio -P


# Root Password

echo "Set the root password."

while true; do
	read -s -p "Enter root password: " ROOTPASS
	echo
	read -s -p "Confirm root password: " ROOTPASS_CONFIRM
	echo

	if [[ -z "$ROOTPASS" ]]; then
		echo "ARCHINATOR Installation script does not support empty root passwords. This is because it is unsafe, and makes sure you think before running commands. I will however, not prevent you from doing this once you have finished installation. I understand this may be required for some usecases, so you can of course disable it after the installation."
		continue
	fi

	if [[ "$ROOTPASS" != "$ROOTPASS_CONFIRM" ]]; then
		echo "Passwords do not match. Try again."
		continue
	fi

	echo "root:${ROOTPASS}" | chpasswd
	echo "Root password set successfully."
	break
done

#user

echo "Username pls"

while true; do
	read -p "Enter username (e.g. yvseann): " NEWUSER

	if [[ -z "$NEWUSER" ]]; then
		echo "Username cannot be empty."
		continue
	fi

	# lowercase, alphanumer, underscore, hyphen

	if [[ "$NEWUSER" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
		echo "Username granted: $NEWUSER"
		break
	else
		echo -e "Invalid username.\nRules:\n- lowercase letters, digits, underscores, hyphens\n- cannot start with a digit"
	fi
done

useradd -m -G wheel -s /bin/bash "$NEWUSER"

echo "Set password for $NEWUSER"
passwd "$NEWUSER"

echo "Configuring sudo..."

sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

echo "Sudo configured: wheel group thingied"

# Boot loader

while true; do
	PS3="Choose a bootloader: "
	select bootloader in "limine" "grub" "systemd-boot" "efistub" "custom"; do
		case $bootloader in
		"limine")
			bootloader="limine"
			echo "Using limine"
			break
			;;
		"grub")
			bootloader="grub"
			echo "Using grub"
			break
			;;
		"systemd-boot")
			bootloader="systemd-boot"
			echo "Using systemd-boot"
			break
			;;
		"efistub")
			bootloader="efistub"
			echo "Using efistub"
			break
			;;
		"custom")
			bootloader="custom"
			echo "You will be prompted to install your own bootloader at the end of the installation."
			break
			;;
		*)
			echo "Invalid selection."
			;;
		esac
	done
	break
done

# set up bootloader

echo "Boot loadering..."

#read -p "Do you want to use secureboot?? (Y/n): " secure_boot
#secure_boot=${secure_boot:-Y}

if [ "$bootloader" = "limine" ]; then
    if [ "$BOOTMODE" = "UEFI" ]; then
		pacman -Syu limine efibootmgr --noconfirm
        mkdir -p /boot/EFI/limine
        cp /usr/share/limine/BOOTX64.EFI /boot/EFI/limine/

        efibootmgr --create --disk ${installation_disk} --part 1 \
      		--label "${HOSTNAME} Limine Bootloader" \
      		--loader '\EFI\limine\BOOTX64.EFI' \
      		--unicode
    fi

	ROOT_UUID=$(blkid -s UUID -o value "$ROOT_PART") # idfk i just found this

	if [[ "$luks_encryption" =~ ^[Yy]$ ]]; then
    	KERNEL_CMDLINE="cryptdevice=UUID=$ROOT_UUID:cryptroot root=/dev/mapper/cryptroot rw"
	else
    	KERNEL_CMDLINE="root=UUID=$ROOT_UUID rw"
	fi

	cat > /boot/limine.conf << EOF

term_palette: 1e1e2e;f38ba8;a6e3a1;f9e2af;89b4fa;f5c2e7;94e2d5;cdd6f4
term_palette_bright: 585b70;f38ba8;a6e3a1;f9e2af;89b4fa;f5c2e7;94e2d5;cdd6f4
term_background: 1e1e2e
term_foreground: cdd6f4
term_background_bright: 585b70
term_foreground_bright: cdd6f4

timeout: 5

/+${HOSTNAME} archlinux-zen
	protocol:linux
	path: boot():/vmlinuz-linux-zen
	cmdline: $KERNEL_CMDLINE
	module_path: boot():/initramfs-linux-zen.img

/+${HOSTNAME} archlinux-lts
	protocol:linux
	path: boot():/vmlinuz-linux-lts
	cmdline: $KERNEL_CMDLINE
	module_path: boot():/initramfs-linux-lts.img

EOF

	#if [[ "$secure_boot" =~ ^[Yy]$ ]]; then
	#	pacman -Syu sbctl --noconfirm
	#fi

fi

# temp stuff because yes.

pacman -Syu xfce4 xfce4-goodies gvfs gvfs-smb network-manager-applet ly --noconfirm
systemctl enable NetworkManager

pacman -Syu ly --noconfirm
systemctl enable ly.service



# todo: secureboot, users, desktop environment, bios, other bootloaders, windows