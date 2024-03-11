#! /bin/bash

SD_HOME=/usr/ss-deployer

. $SD_HOME/generators/lib.sh

inbounds_file=$SD_HOME/xray/confs/inbounds.json

use_xui=0
if [[ -f "/etc/x-ui/x-ui.db" ]]; then
  use_xui=1
fi

is_first_client=1
group_num=0

get_client_start_comma() {
  if [[ $is_first_client -eq 0 ]]; then
    echo ","
  fi
}

# write inbounds file
wi() {
  w $inbounds_file "$1"
}

# write single client
wsc() {
  if [[ $group_num -eq $3 ]]; then
    local comma=$(get_client_start_comma)
    wi "          $comma{"
    wi "            \"password\": \"$2\","
    wi "            \"method\": \"aes-128-gcm\","
    wi "            \"email\": \"$4@mail.com\""
    wi "          }"
    is_first_client=0
  fi
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
  wi "        \"email\": \"$4@mail.com\","
  wi "        \"network\": \"tcp,udp\""
  wi "      }"
  wi "    },"
}

# write single mmp inbound
wsmi() {
  is_first_client=1
  ((++group_num))
  wi "    {"
  wi "      \"tag\": \"$1\","
  wi "      \"port\": $1,"
  wi "      \"protocol\": \"shadowsocks\","
  wi "      \"settings\": {"
  wi "        \"clients\": ["
                for_users wsc
  wi "        ],"
  wi "        \"network\": \"tcp,udp\""
  wi "      }"
  wi "    },"
}

# write reality inbound
wri() {
  if [[ ! -z $reality ]]; then
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
    wi "          \"dest\": \"${rc[1]}:443\","
    wi "          \"serverNames\": ["
    wi "            \"apple.com\","
    wi "            \"www.apple.com\""
    wi "          ],"
    wi "          \"privateKey\": \"${rc[2]}\","
    wi "          \"shortIds\": [\"c1\"]"
    wi "        }"
    wi "      }"
    wi "    },"
  fi
}

rm -rf $inbounds_file
echo "generate xray/inbounds.json"
wi "{"
wi "  \"inbounds\": ["
        if [[ $dtype -eq 2 ]]; then
          wri
        fi
        for_mmp_ports wsmi
        if [[ $use_xui -eq 0 ]]; then
          for_users wsi
        fi
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