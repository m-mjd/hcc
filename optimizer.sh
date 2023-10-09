#!/bin/bash
clear
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RESET='\033[0m'
ascii_art=(
    "${YELLOW} ||''''|                  ."
    " ||  .    ....    ....  .||.    ....  ... .."
    " ||''|   '' .||  ||. '   ||   .|...||  ||' ''"
    " ||      .|' ||  . '|..  ||   ||       ||"
    ".||.     '|..'|' |'..|'  '|.'  '|...' .||.${RESET}"
)

for line in "${ascii_art[@]}"; do
    echo -e "$line"
done

if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}This script must be run with the superuser. Please login with root user.${RESET}"
    exit 1
fi

action=${action:-install}
read -p "Do you want to install or uninstall the cron job? (install/uninstall) [default: install]: " user_action
action=${user_action:-$action}

if [[ $action == install ]]; then
    read -p "Enter the interval in hours to empty the cache (press Enter for default 4 hours): " time
    time=${time:-4}
    if [[ ! $time =~ ^[1-9][0-9]*$ ]]; then
        echo -e "${RED}Invalid input. Please enter a positive integer for the time.${RESET}"
        exit 1
    fi
    time1=$((time*60))
    cron_command="*/$time1 * * * * echo 3 > /proc/sys/vm/drop_caches && swapoff -a && swapon -a && printf '\n%s\n' 'Ram-cache and Swap Cleared'"
    cron_command2="*/$time1 * * * * bash /opt/hiddify-config/apply_configs.sh"
fi

case "$action" in
    uninstall)
        if crontab -l | grep -q "$cron_command"; then
            (crontab -l | grep -v "$cron_command") | crontab -
            echo -e "${GREEN}The command has been successfully removed from cron job.${RESET}"
        else
            echo -e "${YELLOW}The command was not found in the cron job.${RESET}"
        fi
        if crontab -l | grep -q "$cron_command2"; then
            (crontab -l | grep -v "$cron_command2") | crontab -
            echo -e "${GREEN}The command has been successfully removed from cron job.${RESET}"
        else
            echo -e "${YELLOW}The command was not found in the cron job.${RESET}"
        fi
        ;;
    install)
    
        echo 3 > /proc/sys/vm/drop_caches && swapoff -a && swapon -a && printf '\n%s\n'
        bash /opt/hiddify-config/apply_configs.sh
        clear
        if crontab -l | grep -q "$cron_command"; then
            echo -e "${YELLOW}The command is already installed in cron job.${RESET}"
        else
            (crontab -l 2>/dev/null; echo "$cron_command") | crontab -
            echo -e "${GREEN}The command has been successfully added to cron job.${RESET}"
        fi

        if crontab -l | grep -q "$cron_command2"; then  
            echo -e "${YELLOW}The second command is already installed in cron job.${RESET}"
        else
            (crontab -l 2>/dev/null; echo "$cron_command2") | crontab -
            echo -e "${GREEN}The second command has been successfully added to cron job.${RESET}"
        fi
        ;;
    *)
        echo -e "${RED}Invalid option. Please choose 'install' or 'uninstall'.${RESET}"
        exit 1
        ;;
esac
