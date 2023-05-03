#! /bin/bash

SD_HOME=/usr/ss-deployer

. $SD_HOME/generators/lib.sh

inbounds_file=$SD_HOME/xray/confs/inbounds.json

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
  wi "    },"
}

# write reality inbound
wri() {
  rc=($reality)  # reality config
  wi "    {"
  wi "      \"tag\": \"443\","
  wi "      \"listen\": \"0.0.0.0\","
  wi "      \"port\": 443,"
  wi "      \"protocol\": \"vless\","
  wi "      \"settings\": {"
  wi "        \"clients\": [{"
  wi "          \"id\": \"${rc[0]}\","
  wi "          \"flow\": \"xtls-rprx-vision\""
  wi "        }],"
  wi "        \"decryption\": \"none\""
  wi "      },"
  wi "      \"streamSettings\": {"
  wi "        \"network\": \"tcp\","
  wi "        \"security\": \"reality\","
  wi "        \"realitySettings\": {"
  wi "          \"show\": false,"
  wi "          \"dest\": \"microsoft.com:443\","
  wi "          \"serverNames\": ["
  wi "            \"microsoft.com\","
  wi "            \"www.microsoft.com\""
  wi "          ],"
  wi "          \"privateKey\": \"${rc[1]}\","
  wi "          \"shortIds\": [\"c1\"]"
  wi "        }"
  wi "      }"
  wi "    },"
}

rm -rf $inbounds_file
echo "generate xray/inbounds.json"
wi "{"
wi "  \"inbounds\": ["
        if [[ $dtype -eq 2 ]]; then
          wri
        fi
        for_users wsi
wi "    {"
wi "      \"tag\": \"api\","
wi "      \"listen\": \"$ip\","
wi "      \"port\": 10085,"
wi "      \"protocol\": \"dokodemo-door\","
wi "      \"settings\": {"
wi "        \"address\": \"$ip\""
wi "      }"
wi "    }"
wi "  ]"
wi "}"