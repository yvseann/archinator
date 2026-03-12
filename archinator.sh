#!/bin/bash

set -e

# "Small" welcome banner
cat << 'EOF'
 .S_SSSs     .S_sSSs      sSSs   .S    S.    .S   .S_sSSs     .S_SSSs    sdSS_SSSSSSbs    sSSs_sSSs     .S_sSSs    
.SS~SSSSS   .SS~YS%%b    d%%SP  .SS    SS.  .SS  .SS~YS%%b   .SS~SSSSS   YSSS~S%SSSSSP   d%%SP~YS%%b   .SS~YS%%b   
S%S   SSSS  S%S   `S%b  d%S'    S%S    S%S  S%S  S%S   `S%b  S%S   SSSS       S%S       d%S'     `S%b  S%S   `S%b  
S%S    S%S  S%S    S%S  S%S     S%S    S%S  S%S  S%S    S%S  S%S    S%S       S%S       S%S       S%S  S%S    S%S  
S%S SSSS%S  S%S    d*S  S&S     S%S SSSS%S  S&S  S%S    S&S  S%S SSSS%S       S&S       S&S       S&S  S%S    d*S  
S&S  SSS%S  S&S   .S*S  S&S     S&S  SSS&S  S&S  S&S    S&S  S&S  SSS%S       S&S       S&S       S&S  S&S   .S*S  
S&S    S&S  S&S_sdSSS   S&S     S&S    S&S  S&S  S&S    S&S  S&S    S&S       S&S       S&S       S&S  S&S_sdSSS   
S&S    S&S  S&S~YSY%b   S&S     S&S    S&S  S&S  S&S    S&S  S&S    S&S       S&S       S&S       S&S  S&S~YSY%b   
S*S    S&S  S*S   `S%b  S*b     S*S    S*S  S*S  S*S    S*S  S*S    S&S       S*S       S*b       d*S  S*S   `S%b  
S*S    S*S  S*S    S%S  S*S.    S*S    S*S  S*S  S*S    S*S  S*S    S*S       S*S       S*S.     .S*S  S*S    S%S  
S*S    S*S  S*S    S&S   SSSbs  S*S    S*S  S*S  S*S    S*S  S*S    S*S       S*S        SSSbs_sdSSS   S*S    S&S  
SSS    S*S  S*S    SSS    YSSP  SSS    S*S  S*S  S*S    SSS  SSS    S*S       S*S         YSSP~YSSY    S*S    SSS  
       SP   SP                         SP   SP   SP                 SP        SP                       SP          
       Y    Y                          Y    Y    Y                  Y         Y                        Y           
ARCHINATOR - A SCRIPT SOME RANDOM KID MADE BECAUSE THEY WERE BORED!

if you want to change your console font do that before running this script.
EOF

read -n 1 -s -p "Press any button to continue..."
# Is root running this script?
if [ "$(id -u)" -ne 0 ]; then
    echo -e "\n\nCongratulations! You somehow managed to run this script while not in root, in the archiso! How have you managed that? The archiso should be in root. Are you sure you're running an archiso? I really don't recommend using this script on a live machine.\n\n"
    exit 1
fi

echo # just a newline

# prompt user for keymaps and set it

echo -e "About to show all valid keymaps. Once you have picked a keymap press Q to enter the keymap you wish to use."
read -n 1 -s -p "Press any button to continue..."

echo -e "\nAvailable keymaps"
localectl list-keymaps

while true; do
    read -p "Enter the keymap you want (e.g. uk, us, de-latin1): " KEYMAP

    # does the keymap exist?
    if localectl list-keymaps | grep -qx "$KEYMAP"; then
        loadkeys "$KEYMAP"
        echo "Loaded keymap: ${KEYMAP}"
        break
    else
        echo "Invalid keymap: ${KEYMAP}\n"
        echo "Try again.\n"
    fi
done

sleep 1 # go to sleep

# check if uefi or bios

if [ -d /sys/firmware/efi ]; then
    BOOTMODE="UEFI"
else
    BOOTMODE="BIOS"
fi

echo -e "\nBOOT MODE: ${BOOTMODE}\n"

# timedatectl
timedatectl set-ntp true

echo -e "About to show all valid timezones. Once you have picked a timezone press Q to enter the timezone you wish to use."
read -n 1 -s -p "Press any button to continue..."

timedatectl list-timezones
while true; do
    read -p "Enter the timezone you want (e.g. Europe/London): " TIMEZONE

    # does the timezone exist?
    if timedatectl list-timezones | grep -qx "$TIMEZONE"; then
        timedatectl set-timezone "$TIMEZONE"
        echo "Loaded timezone: ${TIMEZONE}"
        break
    else
        echo "Invalid Timezone: ${TIMEZONE}"
        echo "Try again."
    fi
done

timedatectl

sleep 1 # go to sleep

# choose disk and filesystem
lsblk -f
while true; do
    read -p "What disk do you wish to partition on? (e.g. /dev/sda): " installation_disk

    # does the disk exist?

    if [ -b "$installation_disk" ]; then
      echo "Disk Found: ${installation_disk}"

      PS3="Choose a filesystem: "
      select filesystem in "EXT4" "BTRFS"; do
          case $filesystem in
              "EXT4")
                filesystem="ext4"
                echo "Using EXT4"
                break
                ;;
              "BTRFS")
                filesystem="btrfs"
                echo "Using BTRFS"
                break
                ;;
              *)
                echo "Invalid selection."
                ;;
          esac
      done
      break
    fi
done

# partition disk

echo "WARNING: This will ERASE ALL DATA on $installation_disk"
read -p "Type YES to continue (CAPITAL SENSITIVE): " confirm
if [ "$confirm" != "YES" ]; then
    echo "Aborted."
    exit 1
fi

echo "Partitioning disk: $installation_disk"

wipefs -af "$installation_disk"
sgdisk -Zo "$installation_disk"

if [ "$BOOTMODE" = "UEFI" ]; then
    echo "Creating UEFI partitions..."
    sgdisk -n 1:0:+512M -t 1:ef00 "$installation_disk"
    sgdisk -n 2:0:0     -t 2:8300 "$installation_disk"
else
    echo "Creating BIOS partitions..."
    sgdisk -n 1:0:+1M   -t 1:ef02 "$installation_disk"
    sgdisk -n 2:0:0     -t 2:8300 "$installation_disk"
fi

if [[ "$installation_disk" == *"nvme"* ]]; then
    BOOT_PART="${installation_disk}p1"
    ROOT_PART="${installation_disk}p2"
else
    BOOT_PART="${installation_disk}1"
    ROOT_PART="${installation_disk}2"
fi

# format partitions
echo "Formatting partitions..."

if [ "$BOOTMODE" = "UEFI" ]; then
    mkfs.fat -F32 "$BOOT_PART"
fi

if [ "$filesystem" = "ext4" ]; then
    mkfs.ext4 "$ROOT_PART"
elif [ "$filesystem" = "btrfs" ]; then
    mkfs.btrfs -f "$ROOT_PART"
fi

#mount partitions
echo "Mounting partitions..."

if [ "$filesystem" = "ext4" ]; then
    mount "$ROOT_PART" /mnt

    if [ "$BOOTMODE" = "UEFI" ]; then
        mkdir -p /mnt/boot
        mount "$BOOT_PART" /mnt/boot
    fi

elif [ "$filesystem" = "btrfs" ]; then
    mount "$ROOT_PART" /mnt
    btrfs subvolume create /mnt/@
    btrfs subvolume create /mnt/@home
    umount /mnt
    mount -o subvol=@ "$ROOT_PART" /mnt
    mkdir -p /mnt/home
    if [ "$BOOTMODE" = "UEFI" ]; then
        mkdir -p /mnt/boot
    fi
    mount -o subvol=@home "$ROOT_PART" /mnt/home
    if [ "$BOOTMODE" = "UEFI" ]; then
        mount "$BOOT_PART" /mnt/boot
    fi
fi

# swapfile
# read -p "Do you want to create a swapfile? (Y/n): " swap_choice
# if [[ "$swap_choice" =~ ^[Yy]$ ]]; then
#     read -p "Swap size in MiB (e.g. 2048): " swap_size

#     if ! [[ "$swap_size" =~ ^[0-9]+$ ]] || [ "$swap_size" -le 0 ]; then
#         echo "Invalid swap size. Skipping swapfile."
#     else
#         echo "Creating swapfile of ${swap_size}MiB..."
#         dd if=/dev/zero of=/mnt/swapfile bs=1M count="$swap_size" status=progress
#         chmod 600 /mnt/swapfile
#         mkswap /mnt/swapfile
#         swapon /mnt/swapfile
#         echo "Swapfile created and enabled."
#     fi
# fi

clear
lsblk -f