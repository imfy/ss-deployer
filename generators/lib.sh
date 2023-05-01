#! /bin/bash

SD_HOME=/usr/ss-deployer

. $SD_HOME/user_confs

is_first=1

get_end_comma() {
  if [[ $1 -lt $(($2-1)) ]]; then
    echo ","
  fi
}

get_start_comma() {
  if [[ $is_first -eq 0 ]]; then
    echo ","
  fi
}

# write
w() {
  echo "$2" >> $1
}

for_users() {
  local size=${#user_list[@]}
  for((ui=0;ui<${#user_list[@]};ui++)); do
    user=(${user_list[ui]})
    end_comma=$(get_end_comma $ui $size)
    $1 ${user[0]} ${user[1]} ${user[2]} $end_comma
  done
}