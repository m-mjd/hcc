#!/bin/bash
clear
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RESET='\033[0m'
cat << "EOF"
${YELLOW}||''''|                  .
 ||  .    ....    ....  .||.    ....  ... ..
 ||''|   '' .||  ||. '   ||   .|...||  ||' ''
 ||      .|' ||  . '|..  ||   ||       ||
.||.     '|..'|' |'..|'  '|.'  '|...' .||.${RESET}
EOF
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}This script must be run with the superuser. Please login with root user.${RESET}"
    exit 1
fi
read -p "Do you want to install or uninstall the cron job? (install/uninstall): " action
cron_command="*/2 * * * * echo 3 > /proc/sys/vm/drop_caches && swapoff -a && swapon -a && printf '\n%s\n' 'Ram-cache and Swap Cleared'"
case "$action" in
    uninstall)
        if crontab -l | grep -q "$cron_command"; then
            (crontab -l | grep -v "$cron_command") | crontab -
            echo -e "${GREEN}The command has been successfully removed from cron job.${RESET}"
        else
            echo -e "${YELLOW}The command was not found in the cron job.${RESET}"
        fi
        ;;
    install)
        if crontab -l | grep -q "$cron_command"; then
            echo -e "${YELLOW}The command is already installed in cron job.${RESET}"
        else
            (crontab -l 2>/dev/null; echo "$cron_command") | crontab -
            echo -e "${GREEN}The command has been successfully added to cron job.${RESET}"
        fi
        ;;
    *)
        echo -e "${RED}Invalid option. Please choose 'install' or 'uninstall'.${RESET}"
        exit 1
        ;;
esac
