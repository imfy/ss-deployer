#! /bin/bash

SD_HOME=/usr/ss-deployer

. $SD_HOME/generators/lib.sh

inbounds_file=~/xray/confs/inbounds.json

# write inbounds file
wi() {
  w $inbounds_file "$1"
}

# write single inbound
wsi() {
  wi "    {"
  wi "      \"tag\": \"$1\","
  wi "      \"port\": $1,"
  wi "      \"protocol\": \"shadowsocks\","
  wi "      \"settings\": {"
  wi "        \"password\": \"$2\","
  wi "        \"method\": \"aes-128-gcm\","
  wi "        \"network\": \"tcp,udp\""
  wi "      }"
  wi "    }$4"
}

rm -rf $inbounds_file
wi "{"
wi "  \"inbounds\": ["
        for_users wsi
wi "  ]"
wi "}"