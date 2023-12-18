#!/bin/bash

clear

# Your DNSTT Nameserver & your Domain `A` Record
NS='sdns.myudp.elcavlaw.com'
A='myudp.elcavlaw.com'

# Repeat dig cmd loop time (seconds) (positive integer only)
LOOP_DELAY=5

# Number of parallel queries to boost
NUM_PARALLEL=5

# Add your DNS here
declare -a HOSTS=('124.6.181.4')

function endscript() {
  exit 1
}

trap endscript 2 15

# ... (rest of the script remains unchanged)

# Initialize the counter
count=1

check_parallel() {
  local border_color="\e[95m"  # Light magenta color
  local success_color="\e[92m"  # Light green color
  local fail_color="\e[91m"    # Light red color
  local reset_color="\e[0m"    # Reset to default terminal color
  local padding="  "            # Padding for aesthetic

  # Header
  echo -e "${border_color}┌────────────────────────────────────────────────┐${reset_color}"
  echo -e "${border_color}│${reset_color}${padding}DNS Status Check Results (Parallel Boost)${padding}${reset_color}"
  echo -e "${border_color}├────────────────────────────────────────────────┤${reset_color}"
  
  # Results
  for host in "${HOSTS[@]}"; do
    (
      result=$(${_DIG} +timeout=2 +tries=1 "@${host}" ${NS} +short)
      if [ -z "$result" ]; then
        echo -e "${border_color}│${padding}${reset_color}DNS IP: ${host}${reset_color}"
        echo -e "${border_color}│${padding}NameServer: ${NS}${reset_color}"
        echo -e "${border_color}│${padding}Status: ${fail_color}Failed${reset_color}"
      else
        echo -e "${border_color}│${padding}${reset_color}DNS IP: ${host}${reset_color}"
        echo -e "${border_color}│${padding}NameServer: ${NS}${reset_color}"
        echo -e "${border_color}│${padding}Status: ${success_color}Success${reset_color}"
      fi
    ) &
  done
  wait

  # Check count and Loop Delay
  echo -e "${border_color}├────────────────────────────────────────────────┤${reset_color}"
  echo -e "${border_color}│${padding}${reset_color}Check count: ${count}${padding}${reset_color}"
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
  check_parallel
  ((count++))  # Increment the counter
  sleep $LOOP_DELAY
done

exit 0
