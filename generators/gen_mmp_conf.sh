#! /bin/bash

SD_HOME=/usr/ss-deployer
IP_FILE=$SD_HOME/ip
MMP_PORTS_FILE=$SD_HOME/mmp_ports

. $SD_HOME/generators/lib.sh
. $SD_HOME/mmp_ports

mmp_config_file=~/mmp-go/conf.json

wm() {
  w $mmp_config_file "$1"
}

# write single mmp server
wsms() {
  ip=$(cat $IP_FILE)
  wm "        {"
  wm "          \"target\": \"$ip:$1\","
  wm "          \"method\": \"aes-128-gcm\","
  wm "          \"password\": \"$2\""
  wm "        }$4"
}

# write single mmp group
wsmg() {
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
wm "{"
wm "  \"groups\": ["
  for_mmp_ports wsmg
wm "  ]"
wm "}"