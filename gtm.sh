#!/bin/bash
## Copyright ©UDPTeam
## Script to keep-alive your DNSTT server domain record query from target resolver/local dns server
## Run this script excluded to your VPN tunnel (split vpn tunneling mode)
## run command: ./globe-civ3.sh l

## Your DNSTT Nameserver & your Domain `A` Record
NS='sdns.myudph.elcavlaw.com'
A='myudph.elcavlaw.com'

## Repeat dig cmd loop time (seconds) (positive integer only)
LOOP_DELAY=1

## Add your DNS here
declare -a HOSTS=('gtm.palaboy.tech')

## Linux' dig command executable filepath
## Select value: "CUSTOM|C" or "DEFAULT|D"
DIG_EXEC="DEFAULT"
## if set to CUSTOM, enter your custom dig executable path here
CUSTOM_DIG=/data/data/com.termux/files/home/go/bin/fastdig

######################################
######################################
######################################
######################################
######################################
LOG_FILE="dns_keep_alive.log"

case "${DIG_EXEC}" in
DEFAULT|D)
    _DIG="$(command -v dig)"
    ;;
CUSTOM|C)
    _DIG="${CUSTOM_DIG}"
    ;;
esac

if [ ! "$(${_DIG} --version)" ]; then
    printf "%b" "Dig command failed to run, " \
    "please install dig(dnsutils) or check " \
    "\$DIG_EXEC & \$CUSTOM_DIG variable inside $( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )/$(basename "$0") file.\n" && exit 1
fi

log() {
    local timestamp
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] $1" >> "$LOG_FILE"
}

check() {
    for ((i=0; i<"${#HOSTS[*]}"; i++)); do
        for R in "${A}" "${NS}"; do
            T="${HOSTS[$i]}"
            if [[ -z $(timeout -k 10 10 "${_DIG}" @"${T}" "${R}") ]]; then
                M=31
                log "Error: Resolver ${T} for ${R} is unreachable."
            else
                M=32
            fi
            echo -e "\e[1;${M}m\$ R:${R} D:${T}\e[0m"
            unset T R M
        done
    done
}

echo "DNSTT Keep-Alive script <Lantin Nohanih>"
echo -e "DNS List: [\e[1;34m${HOSTS[*]}\e[0m]"
echo "CTRL + C to close script"
((LOOP_DELAY++))
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

exit 0
