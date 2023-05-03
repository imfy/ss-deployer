#! /bin/bash

SD_HOME=/usr/ss-deployer

. $SD_HOME/generators/lib.sh
. $SD_HOME/mmp_ports

mmp_config_file=$SD_HOME/mmp-go/conf.json

group_num=0

wm() {
  w $mmp_config_file "$1"
}

# write single mmp server
wsms() {
  comma=$(get_start_comma)
  if [[ $3 -eq $group_num ]]; then
    wm "        $comma{"
    wm "          \"target\": \"$ip:$1\","
    wm "          \"method\": \"aes-128-gcm\","
    wm "          \"password\": \"$2\""
    wm "        }"
    is_first=0
  fi
}

# write single mmp group
wsmg() {
  ((group_num++))
  is_first=1
  wm "    {"
  wm "      \"name\": \"$1\","
  wm "      \"port\": $1,"
  wm "      \"servers\": ["
              for_users wsms
  wm "      ]"
  wm "    }$2"
}

for_mmp_ports() {
  local size=${#mmp_ports[@]}
  for((pi=0;pi<${#mmp_ports[@]};pi++ )); do
    port=${mmp_ports[pi]}
    end_comma=$(get_end_comma $pi $size)
    $1 $port $end_comma
  done
}

rm -rf $mmp_config_file
echo "generate mmp-go/conf.json"
wm "{"
wm "  \"groups\": ["
  for_mmp_ports wsmg
wm "  ]"
wm "}"