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
EOF

# Is root running this script?
if [ "$(id -u)" -ne 0 ]; then
    echo -e "\n\nTHIS INSTALL SCRIPT MUST BE RUN AS ROOT! WHY IS YOUR ARCHISO NOT IN ROOT?\n\n"
    exit 1
fi

# Prompt user for inputs

read -p "\nEnter the disk to install Arch Linux (e.g. /dev/sda2): " DISK
read -p "Enter the Hostname for this installation: " HOSTNAME
read -p "Enter the locale (e.g., en_US.UTF-8): " LOCALE
read -p "Enter the timezone: " TIMEZONE
read -p "Enter username for the new user: " USER_NAME

# Read back inputs
echo -e "
DISK     :  ${DISK}
HOSTNAME :  ${HOSTNAME}
LOCALE   :  ${LOCALE}
TIMEZONE :  ${TIMEZONE}
USERNAME :  ${USER_NAME}
"

# Prompt user for passwords

while true; do
  read -s -p "Enter password for ${USER_NAME}: " USER_PASSWORD
  echo
  read -s -p "Confirm password: " USER_PASSWORD_CONFIRM
  echo

  if [ "$USER_PASSWORD" = "$USER_PASSWORD_CONFIRM" ]; then
    break
  else
    echo "Passwords do not match. Please try again."
  fi
done

# Make sure DISK is correct
echo "The selected disk is ${DISK}. This will delete all data on this disk."
read -p "Are you sure you want to continue? (yes/No): " CONFIRM

# become lowercase, my string! (what is even going on here)
CONFIRM=$(echo "$CONFIRM" | tr '[:upper:]' '[:lower:]')

if [ "$CONFIRM" != "yes" ] && [ "$CONFIRM" != "y" ]; then
  echo "Operation cancelled."
  exit 1
fi
