#! /bin/bash

SD_HOME=/usr/ss-deployer

. $SD_HOME/dest_confs
. $SD_HOME/generators/lib.sh

outbounds_file=~/xray/confs/outbounds.json

is_first=1

# write outbounds file
wo() {
  w $outbounds_file "$1"
}

# write single outbound
wso() {
  is_first=0
  wo "    $6{"
  wo "      \"tag\": \"obs-$3-$1\","
  wo "      \"protocol\": \"shadowsocks\","
  wo "      \"settings\": {"
  wo "        \"servers\": [{"
  wo "          \"address\": \"$2\","
  wo "          \"port\": $5,"
  wo "          \"password\": \"$4\","
  wo "          \"method\": \"aes-128-gcm\""
  wo "        }]"
  wo "      }"
  wo "    }"
}

get_comma() {
  if [[ $is_first -eq 0 ]]; then
    echo ","
  fi
}

# write single user outbound
wsuo() {
  for line in "${common_dest_list[@]}"; do
    local route=($line)
    local comma=$(get_comma)
    dest_port=${route[2]: 0: 4}$3
    wso ${route[0]} ${route[1]} $1 $2 $dest_port $comma
  done
  for line in "${tcp_dest_list[@]}"; do
    local route=($line)
    local comma=$(get_comma)
    dest_port=${route[2]: 0: 4}$3
    wso ${route[0]} ${route[1]} $1 $2 $dest_port $comma
  done
  for line in "${udp_dest_list[@]}"; do
    local route=($line)
    local comma=$(get_comma)
    dest_port=${route[2]: 0: 4}$3
    wso ${route[0]} ${route[1]} $1 $2 $dest_port $comma
  done
}

rm -rf $outbounds_file
wo "{"
wo "  \"outbounds\": ["
  for_users wsuo
wo "  ]"
wo "}"