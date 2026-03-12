#!/bin/bash

#time
echo "Setting time..."
ln -sf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime
hwclock --systohc
timedatectl

sleep 1

# localization
echo "Setting localization..."
sleep 0.5

locale-gen
echo "Available locales:"
grep -E '^[a-zA-Z]' /etc/locale.gen | awk '{print $1}'
while true; do
    read -p "Enter the locale you want (e.g. en_GB.UTF-8): " LOCALIZATION

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

echo "Generating locale..."
locale-gen

echo "Setting system default locale..."
echo "LANG=${LOCALIZATION}" > /etc/locale.conf

echo "Setting keymap..."
cat KEYMAP={KEYMAP} > /etc/vconsole.conf