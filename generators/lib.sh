#! /bin/bash

SD_HOME=/usr/ss-deployer

. $SD_HOME/user_confs

get_end_comma() {
  if [[ $1 -lt $(($2-1)) ]]; then
    echo ","
  fi
}

get_start_comma() {
  if [[ $1 -ne 1 ]]; then
    echo ","
  fi
}

# write
w() {
  echo "$2" >> $1
}

for_users() {
  local user_list=("${user_list_1[@]}" "${user_list_2[@]}")
  local size=${#user_list[@]}
  local i=0
  for user in "${user_list_1[@]}"; do
    port=${user[0]}
    password=${user[1]}
    end_comma=$(get_end_comma $i $size)
    $1 $port $password 8 $end_comma
    ((i++))
  done
    for user in "${user_list_2[@]}"; do
      port=${user[0]}
      password=${user[1]}
      end_comma=$(get_end_comma $i $size)
      $1 $port $password 8 $end_comma
      ((i++))
    done
#  for((ui=0;ui<${#user_list[@]};ui++ )); do
#    user=(${user_list[ui]})
#    port=${user[0]}
#    password=${user[1]}
#    end_comma=$(get_end_comma $ui $size)
#    $1 $port $password $end_comma
#  done
}