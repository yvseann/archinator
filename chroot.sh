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
    if grep -q "^#\?${LOCALIZATION} " /etc/locale.gen; then
        echo "Locale valid: ${LOCALIZATION}"
        break
    else
        echo "Invalid locale: ${LOCALIZATION}"
        echo "Try again."
    fi
done

echo "Enabling locale..."
sed -i "s/^#${LOCALIZATION}/${LOCALIZATION}/" /etc/locale.gen

echo "Setting system default locale..."
echo "LANG=${LOCALIZATION}" > /etc/locale.conf

echo "Generating locale..."
locale-gen

#keymap
echo "Setting keymap..."
echo "KEYMAP=${KEYMAP}" > /etc/vconsole.conf

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

echo "$HOSTNAME" > /etc/hostname
echo "Hostname ${HOSTNAME} has been set."

# Initramfs

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