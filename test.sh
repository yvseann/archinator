DISK=$(dialog --stdout \
    --title "Select Installation Disk" \
    --menu "Choose a disk:" 0 0 0 \
    $(lsblk -dpno NAME,SIZE | awk '{print $1, $2}'))
