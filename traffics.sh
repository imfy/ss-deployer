#!/bin/bash

SD_HOME=/usr/ss-deployer

. $SD_HOME/generators/lib.sh

get_cost() {
  echo $1:
  xray api statsquery --server=$ip:10085 -pattern "$1@mail.com" \
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
          printf "%.0f GB\n", cost/1073741824;
        } else if (cost > 1024*1024) {
          printf "%.0f MB\n", cost/1048576;
        } else if (cost > 1024) {
          printf "%.0f KB\n", cost/1024;
        } else {
          printf "%.0f \n", cost;
        }
      }
      else if (match($0, /}/) && f) { f = 0; print 0; }
  }'
}

watch_traffics() {
  for line in "${user_list[@]}"; do
    user=($line)
    get_cost ${user[3]}
  done
}

watch_traffics