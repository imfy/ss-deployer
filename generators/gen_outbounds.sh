#! /bin/bash

SD_HOME=/usr/ss-deployer

. $SD_HOME/dest_confs
. $SD_HOME/generators/lib.sh

outbounds_file=$SD_HOME/xray/confs/outbounds.json

is_first=1

ss_dest_list=("${ss_common_dest_list[@]}" "${ss_tcp_dest_list[@]}" "${ss_udp_dest_list[@]}")

# write outbounds file
wo() {
  w $outbounds_file "$1"
}

# write single outbound
wso() {
  comma=$(get_start_comma)
  is_first=0
  wo "    $comma{"
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

# write single reality outbound
wsro() {
  comma=$(get_start_comma)
  is_first=0
  wo "    $comma{"
  wo "      \"tag\": \"obs-$1\","
  wo "      \"protocol\": \"vless\","
  wo "      \"settings\": {"
  wo "        \"vnext\": [{"
  wo "          \"address\": \"$2\","
  wo "          \"port\": 443,"
  wo "          \"users\": [{"
  wo "            \"id\": \"$4\","
  wo "            \"flow\": \"xtls-rprx-vision\","
  wo "            \"encryption\": \"none\""
  wo "          }]"
  wo "        }]"
  wo "      },"
  wo "      \"streamSettings\": {"
  wo "        \"network\": \"tcp\","
  wo "        \"security\": \"reality\","
  wo "        \"realitySettings\": {"
  wo "          \"show\": false,"
  wo "          \"fingerprint\": \"chrome\","
  wo "          \"serverName\": \"$3\","
  wo "          \"publicKey\": \"$5\","
  wo "          \"shortId\": \"c1\","
  wo "          \"spiderX\": \"/\""
  wo "        }"
  wo "      }"
  wo "    }"
}

rm -rf $outbounds_file
echo "generate xray/outbounds.json"
wo "{"
wo "  \"outbounds\": ["
  for line in "${reality_dest_list[@]}"; do
    route=($line)
    wsro ${route[0]} ${route[1]} ${route[2]} ${route[3]} ${route[4]}
  done
  for line in "${ss_dest_list[@]}"; do
    route=($line)
    wso ${route[0]} ${route[1]} ${route[2]} ${route[3]}
  done
wo "  ]"
wo "}"