#! /bin/bash

SD_HOME=/usr/ss-deployer

. $SD_HOME/dest_confs
. $SD_HOME/generators/lib.sh

routing_file=$SD_HOME/xray/confs/routing.json

tcp_dest_list=("${reality_dest_list[@]}" "${ss_common_dest_list[@]}" "${ss_tcp_dest_list[@]}")
udp_dest_list=("${ss_common_dest_list[@]}" "${ss_udp_dest_list[@]}")

# write routing file
wr() {
  w $routing_file "$1"
}

# write single balancer
wsb() {
  if [[ ${#tcp_dest_list[@]} -gt 0 ]]; then
    wr "      {"
    wr "        \"tag\": \"balancer-tcp\","
    wr "        \"selector\": ["
    for line in "${tcp_dest_list[@]}"; do
      local route=($line)
      local comma=$(get_start_comma)
      wr "          $comma\"obs-${route[0]}\""
      is_first=0
    done
    wr "        ],"
    wr "        \"strategy\": {\"type\": \"leastPing\"}"
    wr "      }"
  fi
  is_first=1
  if [[ ${#udp_dest_list[@]} -gt 0 ]]; then
    wr "      ,{"
    wr "        \"tag\": \"balancer-udp\","
    wr "        \"selector\": ["
    for line in "${udp_dest_list[@]}"; do
      local route=($line)
      local comma=$(get_start_comma)
      wr "          $comma\"obs-${route[0]}\""
      is_first=0
    done
    wr "        ],"
    wr "        \"strategy\": {\"type\": \"leastPing\"}"
    wr "      }"
  fi
}

# write single rule
wsr() {
  if [[ ${#tcp_dest_list[@]} -gt 0 ]]; then
    local comma=$(get_start_comma)
    wr "      $comma{"
    wr "        \"inboundTag\": [\"$1\"],"
    wr "        \"balancerTag\": \"balancer-tcp\","
    wr "        \"network\": \"tcp\","
    wr "        \"type\": \"field\""
    wr "      }"
    is_first=0
  fi
  if [[ ${#udp_dest_list[@]} -gt 0 ]]; then
    local comma=$(get_start_comma)
    wr "      $comma{"
    wr "        \"inboundTag\": [\"$1\"],"
    wr "        \"balancerTag\": \"balancer-udp\","
    wr "        \"network\": \"udp\","
    wr "        \"type\": \"field\""
    wr "      }"
    is_first=0
  fi
}

rm -rf $routing_file
wr "{"
wr "  \"routing\": {"
wr "    \"balancers\": ["
          wsb
wr "    ],"
is_first=1
wr "    \"rules\": ["
          for_users wsr
wr "    ]"
wr "  }"
wr "}"