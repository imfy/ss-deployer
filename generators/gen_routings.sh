#! /bin/bash

SD_HOME=/usr/ss-deployer

. $SD_HOME/dest_confs
. $SD_HOME/generators/lib.sh

routing_file=~/xray/confs/routing.json

# write routing file
wr() {
  w $routing_file "$1"
}

# write single balancer
wsb() {
  local i=1
  wr "      {"
  wr "        \"tag\": \"b$1-tcp\","
  wr "        \"selector\": ["
  for line in "${common_dest_list[@]}"; do
    local route=($line)
    local comma=$(get_start_comma $i)
    wr "          $comma\"obs-$1-${route[0]}\""
    ((i++))
  done
  for line in "${tcp_dest_list[@]}"; do
    local route=($line)
    local comma=$(get_start_comma $i)
    wr "          $comma\"obs-$1-${route[0]}\""
    ((i++))
  done
  wr "        ],"
  wr "        \"strategy\": {\"type\": \"leastPing\"}"
  wr "      },"
  i=1
  wr "      {"
  wr "        \"tag\": \"b$1-udp\","
  wr "        \"selector\": ["
  for line in "${common_dest_list[@]}"; do
    local route=($line)
    local comma=$(get_start_comma $i)
    wr "          $comma\"obs-$1-${route[0]}\""
    ((i++))
  done
  for line in "${udp_dest_list[@]}"; do
    local route=($line)
    local comma=$(get_start_comma $i)
    wr "          $comma\"obs-$1-${route[0]}"
    ((i++))
  done
  wr "        ],"
  wr "        \"strategy\": {\"type\": \"leastPing\"}"
  wr "      }$4"
}

# write single rule
wsr() {
  wr "      {"
  wr "        \"inboundTag\": [\"$1\"],"
  wr "        \"balancerTag\": \"b$1-tcp\","
  wr "        \"network\": \"tcp\","
  wr "        \"type\": \"field\""
  wr "      },"
  wr "      {"
  wr "        \"inboundTag\": [\"$1\"],"
  wr "        \"balancerTag\": \"b$1-udp\","
  wr "        \"network\": \"udp\","
  wr "        \"type\": \"field\""
  wr "      }$4"
}

rm -rf $routing_file
wr "{"
wr "  \"routing\": {"
wr "    \"balancers\": ["
          for_users wsb
wr "    ],"
wr "    \"rules\": ["
          for_users wsr
wr "    ]"
wr "  }"
wr "}"