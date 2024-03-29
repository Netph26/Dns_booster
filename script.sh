#!/bin/bash

clear

function endscript() {
  exit 1
}

trap endscript 2 15

# Your DNSTT Nameservers & your Domain A Record
declare -a NAMESERVERS=('ns.james.palaboy.tech' 'sdns.myudp2.elcavlaw.com')
declare -a HOSTS=('124.6.181.4' 'gtm.lantindns.tech')

LOOP_DELAY=4

echo -e "\e[1;37mCurrent loop delay is \e[1;33m${LOOP_DELAY}\e[1;37m seconds.\e[0m"
read -p "Would you like to change the loop delay? [y/n]: " change_delay

if [[ "$change_delay" == "y" ]]; then
  read -p "Enter custom loop delay in seconds (5-15): " custom_delay
  if [[ "$custom_delay" =~ ^[5-9]$|^1[0-5]$ ]]; then
    LOOP_DELAY=$custom_delay
  else
    echo -e "\e[1;31mInvalid input. Using default loop delay of ${LOOP_DELAY} seconds.\e[0m"
  fi
fi

DIG_EXEC="DEFAULT"
CUSTOM_DIG="/data/data/com.termux/files/home/go/bin/fastdig"
VER=0.3

_DIG=""

case "${DIG_EXEC}" in
  DEFAULT|D)
    _DIG="dig"
    ;;
  CUSTOM|C)
    _DIG="${CUSTOM_DIG}"
    ;;
esac

if ! command -v "${_DIG}" &>/dev/null; then
  printf "%b" "Dig command failed to run. Please install dig (dnsutils) or check the DIG_EXEC & CUSTOM_DIG variable.\n" && exit 1
fi

# Initialize the counter
count=1

# Check function modified to use provided DNS TT nameserver and domain A record
check() {
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

  # Perform asynchronous DNS queries
  for T in "${HOSTS[@]}"; do
    (
      result=$(${_DIG} +short @"${T}" "${NAMESERVERS[@]}")
      if [ -z "$result" ]; then
        STATUS="${fail_color}Failed${reset_color}"
      else
        STATUS="${success_color}Success${reset_color}"
      fi
      echo -e "${border_color}│${padding}${reset_color}DNS IP: ${T}${reset_color}"
      for NS in "${NAMESERVERS[@]}"; do
        echo -e "${border_color}│${padding}NameServer: ${NS}${reset_color}"
      done
      echo -e "${border_color}│${padding}Status: ${STATUS}${reset_color}"
    ) &
  done

  wait  # Wait for all background processes to finish

  # Check count and Loop Delay
  echo -e "${border_color}├────────────────────────────────────────────────┤${reset_color}"
  echo -e "${border_color}│${padding}${header_color}Check count: ${count}${padding}${reset_color}"
  echo -e "${border_color}│${padding}Loop Delay: ${LOOP_DELAY} seconds${padding}${reset_color}"

  # Footer
  echo -e "${border_color}└────────────────────────────────────────────────┘${reset_color}"
}

# Countdown function
countdown() {
    for i in {3..1}; do
        echo "Checking will start in $i seconds..."
        sleep 1
    done
}

countdown
clear

# Main loop
while true; do
  check
  ((count++))  # Increment the counter
  sleep $LOOP_DELAY
done

exit 0
