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
  wo "    $5{"
  wo "      \"tag\": \"obs-$1\","
  wo "      \"protocol\": \"shadowsocks\","
  wo "      \"settings\": {"
  wo "        \"servers\": [{"
  wo "          \"address\": \"$2\","
  wo "          \"port\": $3,"
  wo "          \"password\": \"$4\","
  wo "          \"method\": \"aes-128-gcm\""
  wo "        }]"
  wo "      }"
  wo "    }"
}

rm -rf $outbounds_file
wo "{"
wo "  \"outbounds\": ["
  for line in "${ss_common_dest_list[@]}"; do
    route=($line)
    comma=$(get_start_comma)
    wso ${route[0]} ${route[1]} ${route[2]} ${route[3]} $comma
  done
  for line in "${ss_tcp_dest_list[@]}"; do
    route=($line)
    comma=$(get_start_comma)
    wso ${route[0]} ${route[1]} ${route[2]} ${route[3]} $comma
  done
  for line in "${ss_udp_dest_list[@]}"; do
    route=($line)
    comma=$(get_start_comma)
    wso ${route[0]} ${route[1]} ${route[2]} ${route[3]} $comma
  done
wo "  ]"
wo "}"