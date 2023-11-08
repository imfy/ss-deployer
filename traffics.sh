#!/bin/bash

SD_HOME=/usr/ss-deployer

. $SD_HOME/generators/lib.sh

get_cost() {
  xray api statsquery --server=$ip:10085 -pattern "$1@mail.com>>>traffic>>>$2" \
  | awk '{
      if (match($1, /"name":/)) {
          f = 1; gsub(/^"|link"|,$/, "", $2);
          split($2, p,  ">>>");
          printf "  ---->%s\t",p[4];
      }
      else if (match($1, /"value":/) && f){
        f = 0; gsub(/"/, "", $2);
        cost=$2+0
        if (cost > 1073741824) {
          printf "%.2f GB", cost/1073741824;
        } else if (cost > 1024*1024) {
          printf "%.2f MB", cost/1048576;
        } else if (cost > 1024) {
          printf "%.2f KB", cost/1024;
        } else {
          printf "%.0f", cost;
        }
        printf " (%.0f)\n", cost;
      }
      else if (match($0, /}/) && f) { f = 0; print 0; }
  }'
}

watch_traffics() {
  for line in "${user_list[@]}"; do
    user=($line)
    echo ${user[3]}:
    get_cost ${user[3]} "uplink"
    get_cost ${user[3]} "downlink"
  done
}

watch_traffics