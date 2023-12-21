
#!/bin/bash
# Copyright © UDPTeam
# Discord: https://discord.gg/civ3
# Script to keep-alive your DNSTT server domain record query from target resolver/local dns server
# Run this script excluded to your VPN tunnel (split vpn tunneling mode)
# Run command: ./globe-killfreenet3.sh l

# Your DNSTT Nameserver & your Domain `A` Record
NS='sdns.myudp.elcavlaw.com'

# Add your DNS here
declare -a HOSTS=('gtm.lantindns.tech')

# Linux' dig command executable filepath
# Select value: "CUSTOM|C" or "DEFAULT|D "
DIG_EXEC="DEFAULT"

# If set to CUSTOM, enter your custom dig executable path here
CUSTOM_DIG="/data/data/com.termux/files/home/go/bin/fastdig"

# Set loop delay
LOOP_DELAY=1

# Determine the dig executable
case "${DIG_EXEC}" in
  DEFAULT|D)
    _DIG="$(command -v dig)"
    ;;
  CUSTOM|C)
    _DIG="${CUSTOM_DIG}"
    ;;
esac

# Check if dig is available
if [ ! "$_DIG" ]; then
  printf "Error: Dig command not found. Please install dig (dnsutils) or check DIG_EXEC & CUSTOM_DIG variables.\n"
  exit 1
fi

# Function to check DNS
check() {
  for host in "${HOSTS[@]}"; do
    for record in "${A}" "${NS}"; do
      if timeout -k 3 3 "${_DIG}" "@${host}" "${record}" &>/dev/null; then
        color_code=31
      else
        color_code=32
      fi
      echo -e "\e[${color_code}m${record} D:${host}\e[0m"
    done
  done
}

# Trap signals for cleanup
trap 'echo "Script terminated." && exit 1' 2 15

echo "DNSTT Keep-Alive script <Discord @civ3>"
echo -e "DNS List: [${HOSTS[*]}]"
echo "CTRL + C to close script"

# Increment LOOP_DELAY if it is 1
[ "${LOOP_DELAY}" -eq 1 ] && ((LOOP_DELAY++))

case "${@}" in
  loop|l)
    echo "Script loop: ${LOOP_DELAY} seconds"
    while true; do
      check
      echo '.--. .-.. . .- ... .     .-- .- .. -'
      sleep "${LOOP_DELAY}"
    done
    ;;
  *)
    check
    ;;
esac

exit
