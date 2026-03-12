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

sleep 1

# check if uefi or bios

if [ -d /sys/firmware/efi ]; then
    BOOTMODE="UEFI"
else
    BOOTMODE="BIOS"
fi

echo -e "\nBOOT MODE: ${BOOTMODE}\n"

# timedatectl
timedatectl set-ntp true

echo -e "About to show all valid languages. Once you have picked a keymap press Q to enter the language you wish to use."
read -n 1 -s -p "Press any button to continue..."
while true; do
    read -p "Enter the timezone you want (e.g. Europe/London): " TIMEZONE

    # does the keymap exist?
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