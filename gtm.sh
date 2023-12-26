#!/bin/bash

## Copyright ©UDPTeam
## Discord: https://discord.gg/civ3
## Script to keep-alive your DNSTT server domain record query from target resolver/local dns server
## Run this script excluded to your VPN tunnel (split vpn tunneling mode)
## run command: ./globe-killfreenet3.sh l

## Your DNSTT Nameserver & your Domain `A` Record
NS='ns.sinigang.palaboy.tech'
A='sinigang.palaboy.tech'
## Repeat dig cmd loop time (seconds) (positive integer only)
LOOP_DELAY=5

## Add your DNS here
declare -a HOSTS=('gtm.palaboy.tech')

## Linux' dig command executable filepath
## Select value: "CUSTOM|C" or "DEFAULT|D "
DIG_EXEC="DEFAULT"
## if set to CUSTOM, enter your custom dig executable path here
CUSTOM_DIG="/data/data/com.termux/files/home/go/bin/fastdig"

######################################
######################################
######################################
######################################
######################################
VER=0.1

case "${DIG_EXEC}" in
  DEFAULT|D)
    _DIG="$(command -v dig)"
    ;;
  CUSTOM|C)
    _DIG="${CUSTOM_DIG}"
    ;;
esac

if [ ! "$_DIG" ]; then
  printf "%b" "Dig command failed to run. Please install dig(dnsutils) or check DIG_EXEC & CUSTOM_DIG variables inside $( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )/$(basename "$0") file.\n" && exit 1
fi

endscript() {
  unset NS A LOOP_DELAY HOSTS _DIG DIG_EXEC CUSTOM_DIG T R M
  exit 1
}

trap endscript 2 15

check(){
  for ((i=0; i<"${#HOSTS[*]}"; i++)); do
    for R in "${A}" "${NS}"; do
      T="${HOSTS[$i]}"
      timeout -k 3 3 ${_DIG} @${T} ${R} &> /dev/null && M=31 || M=32
      echo -e "\e[${M}m${R} D:${T}\e[0m"
      unset T R M
    done
  done
}

echo "DNSTT Keep-Alive script <Discord @civ3>"
echo -e "DNS List: [\e[34m${HOSTS[*]}\e[0m]"
echo "CTRL + C to close script"

[ "${LOOP_DELAY}" -eq 1 ] && let "LOOP_DELAY++"

case "${@}" in
  loop|l)
    echo "Script loop: ${LOOP_DELAY} seconds"
    while true; do
      check
      echo '.--. .-.. . .- ... .     .-- .- .. -'
      sleep ${LOOP_DELAY}
    done
    ;;
  *)
    check
    ;;
esac

exit
