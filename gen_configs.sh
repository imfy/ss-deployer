#! /bin/bash

SD_HOME=/usr/ss-deployer
IP_FILE=$SD_HOME/ip
SS_PORTS_FILE=$SD_HOME/ss_ports
MMP_PORTS_FILE=$SD_HOME/mmp_ports

mmp_config_file=~/mmp-go/conf.json
inbounds_file=~/xray/confs/inbounds.json
outbounds_file=~/xray/confs/outbounds.json
routing_file=~/xray/confs/routing.json

# get comma
get_comma() {
#  if [[ $1 -lt $(($2-1)) ]]; then
  if [[ $1 -lt $2 ]]; then
    echo ","
  fi
}

# write
w() {
  echo "$2" >> $1
}

# write inbounds file
wi() {
  w $inbounds_file "$1"
}

# write outbounds file
wo() {
  w $outbounds_file "$1"
}

wm() {
  w $mmp_config_file "$1"
}

# write routing file
wr() {
  w $routing_file "$1"
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
  wi "    }$3"
}

# write single balancer
wsb() {
  wr "    {"
  wr "      \"tag\": \"b$1\","
  wr "      \"selector\": [],"
  wr "      \"strategy\": [\"type\": \"leastload\"]"
  wr "    }$3"
}

# write single mmp
wsm() {
  ip=$(cat $IP_FILE)
  wm "        {"
  wm "          \"target\": \"$ip:$1\","
  wm "          \"method\": \"aes-128-gcm\","
  wm "          \"password\": \"$2\""
  wm "        }$3"
}

# write single rule
#wsr() {
#
#
#}

for_ports() {
  i=1
  count=$(grep -c "" $SS_PORTS_FILE)
  cat $SS_PORTS_FILE | while read line; do
    conf=(${line})
    port=${conf[0]}
    password=${conf[1]}
    comma=$(get_comma $i $count)
    $1 $port $password $comma
    ((i++))
  done
}


# 创建mmp-go的config.json
ports=($(cat $MMP_PORTS_FILE))
rm -rf $mmp_config_file
wm "{"
wm "  \"groups\": ["
wm "    {"
wm "      \"name\": \"${ports[0]}\","
wm "      \"port\": ${ports[0]},"
wm "      \"servers\": ["
            for_ports wsm
wm "      ]"
wm "    },"
wm "    {"
wm "      \"name\": \"${ports[1]}\","
wm "      \"port\": ${ports[1]},"
wm "      \"servers\": ["
            for_ports wsm
wm "      ]"
wm "    }"
wm "  ]"
wm "}"


# 创建inbounds.json
rm -rf $inbounds_file
wi "{"
wi "  \"inbounds\": ["
        for_ports wsi
wi "  ]"
wi "}"


# 创建outbounds.json
# rm -rf $outbounds_file
# wo "{"
# wo "  \"outbounds\": ["
# # for i in "${!configs[@]}"; do
# #   config=(${configs[$i]})
# #   port=${config[0]}
# #   password=${config[1]}
# #   echo "    {" >> $inbounds_file
# #   echo "      \"tag\": \"${port}\"," >> $inbounds_file
# #   echo "      \"port\": ${port}," >> $inbounds_file
# #   echo "      \"protocol\": \"shadowsocks\"," >> $inbounds_file
# #   echo "      \"settings\": {" >> $inbounds_file
# #   echo "        \"password\": \"${password}\"," >> $inbounds_file
# #   echo "        \"method\": \"aes-128-gcm\"," >> $inbounds_file
# #   echo "        \"network\": \"tcp,udp\"" >> $inbounds_file
# #   echo "      }" >> $inbounds_file
# #   if [[ $i -lt $((${#configs[@]}-1)) ]]; then
# #     echo "    }," >> $inbounds_file
# #   else
# #     echo "    }" >> $inbounds_file
# #   fi
# # done
# wo "  ]"
# wo "}"


# 创建routing.json
#rm -rf $routing_file
#wr "{"
#wr "  \"routing\": {"
#wr "    \"balancers\": ["
#          for_ports wsb
#wr "    ],"
#wr "    rules: ["
#          for_ports wsr
#wr "    ]"
#wr "  }"
#wr "}"

## 启动各项服务
chmod +x mmp-go/mmp-go
chmod +x xray/xray
./mserver.sh
./xserver.sh
if [[ $1 == "f" ]]; then
  chmod +x naive/naive
  ./nserver;
fi