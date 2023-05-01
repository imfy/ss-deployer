#! /bin/bash

SD_HOME=/usr/ss-deployer

. $SD_HOME/dest_confs
. $SD_HOME/generators/lib.sh

routing_file=$SD_HOME/xray/confs/routing.json

# write routing file
wr() {
  w $routing_file "$1"
}

# write single balancer
wsb() {
  wr "      {"
  wr "        \"tag\": \"balancer-tcp\","
  wr "        \"selector\": ["
  for line in "${ss_common_dest_list[@]}"; do
    local route=($line)
    local comma=$(get_start_comma)
    wr "          $comma\"obs-${route[0]}\""
    is_first=0
  done
  for line in "${ss_tcp_dest_list[@]}"; do
    local route=($line)
    local comma=$(get_start_comma)
    wr "          $comma\"obs-${route[0]}\""
    is_first=0
  done
  wr "        ],"
  wr "        \"strategy\": {\"type\": \"leastPing\"}"
  wr "      },"
  is_first=1
  wr "      {"
  wr "        \"tag\": \"balancer-udp\","
  wr "        \"selector\": ["
  for line in "${ss_common_dest_list[@]}"; do
    local route=($line)
    local comma=$(get_start_comma)
    wr "          $comma\"obs-${route[0]}\""
    is_first=0
  done
  for line in "${ss_udp_dest_list[@]}"; do
    local route=($line)
    local comma=$(get_start_comma)
    wr "          $comma\"obs-${route[0]}"
    is_first=0
  done
  wr "        ],"
  wr "        \"strategy\": {\"type\": \"leastPing\"}"
  wr "      }"
}

# write single rule
wsr() {
  wr "      {"
  wr "        \"inboundTag\": [\"$1\"],"
  wr "        \"balancerTag\": \"balancer-tcp\","
  wr "        \"network\": \"tcp\","
  wr "        \"type\": \"field\""
  wr "      },"
  wr "      {"
  wr "        \"inboundTag\": [\"$1\"],"
  wr "        \"balancerTag\": \"balancer-udp\","
  wr "        \"network\": \"udp\","
  wr "        \"type\": \"field\""
  wr "      }$4"
}

rm -rf $routing_file
wr "{"
wr "  \"routing\": {"
wr "    \"balancers\": ["
          wsb
wr "    ],"
wr "    \"rules\": ["
          for_users wsr
wr "    ]"
wr "  }"
wr "}"