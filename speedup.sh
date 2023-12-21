#!/bin/bash

clear

function endscript() {
  exit 1
}

trap endscript 2 15

echo -e "\e[1;37mEnter DNS IPs separated by ' ': \e[0m"
read -ra DNS_IPS

echo -e "\e[1;37mEnter Your NameServers separated by ' ': \e[0m"
read -ra NAME_SERVERS

LOOP_DELAY=4
echo -e "\e[1;37mCurrent loop delay is \e[1;33m${LOOP_DELAY}\e[1;37m seconds.\e[0m"
echo -e "\e[1;37mWould you like to change the loop delay? \e[1;36m[y/n]:\e[0m "
read -r change_delay

if [[ "$change_delay" == "y" ]]; then
  echo -e "\e[1;37mEnter custom loop delay in seconds \e[1;33m(5-15):\e[0m "
  read -r custom_delay
  if [[ "$custom_delay" =~ ^[5-9]$|^1[0-5]$ ]]; then
    LOOP_DELAY=$custom_delay
  else
    echo -e "\e[1;31mInvalid input. Using default loop delay of ${LOOP_DELAY} seconds.\e[0m"
  fi
fi

DIG_EXEC="DEFAULT"
CUSTOM_DIG=/data/data/com.termux/files/home/go/bin/fastdig
VER=0.3

case "${DIG_EXEC}" in
  DEFAULT|D)
    _DIG="$(command -v dig)"
    ;;
  CUSTOM|C)
    _DIG="${CUSTOM_DIG}"
    ;;
esac

if [ ! "$(command -v "${_DIG}")" ]; then
  printf "%b" "Dig command failed to run, please install dig(dnsutils) or check the DIG_EXEC & CUSTOM_DIG variable.\n" && exit 1
fi

# Initialize the counter
count=1

check(){
  local border_color="\e[95m"  # Light magenta color
  local success_color="\e[92m"  # Light green color
  local fail_color="\e[91m"    # Light red color
  local header_color="\e[96m"  # Light cyan color
  local reset_color="\e[0m"    # Reset to default terminal color
  local padding="  "            # Padding for aesthetic

  # Header
  echo -e "${border_color}┌────────────────────────────────────────────────┐${reset_color}"
  echo -e "${border_color}│${header_color}${padding}DNS Status Check Results${padding}${reset_color}"
  echo -e "${border_color}├────────────────────────────────────────────────┤${reset_color}"
  
  # Results
  for T in "${DNS_IPS[@]}"; do
    for R in "${NAME_SERVERS[@]}"; do
      result=$("${_DIG}" @"${T}" "${R}" +short)
      if [ -z "$result" ]; then
        STATUS="${fail_color}Failed${reset_color}"
      else
        STATUS="${success_color}Success${reset_color}"
      fi
      echo -e "${border_color}│${padding}${reset_color}DNS IP: ${T}${reset_color}"
      echo -e "${border_color}│${padding}NameServer: ${R}${reset_color}"
      echo -e "${border_color}│${padding}Status: ${STATUS}${reset_color}"
    done
  done

  # Check count and Loop Delay
  echo -e "${border_color}├────────────────────────────────────────────────┤${reset_color}"
  echo -e "${border_color}│${padding}${header_color}Check count: ${count}${padding}${reset_color}"
  echo -e "${border_color}│${padding}Loop Delay: ${LOOP_DELAY} seconds${padding}${reset_color}"
  
  # Footer
  echo -e "${border_color}└────────────────────────────────────────────────┘${reset_color}"
}

countdown() {
    for i in 1 0; do
        echo "Checking started in $i seconds..."
        sleep 1
    done
}


countdown
  clear

# Main loop
while true; do
  check
  ((count++))  # Increment the counter
  sleep "$LOOP_DELAY"
done

exit 0
