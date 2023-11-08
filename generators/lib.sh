#! /bin/bash

SD_HOME=/usr/ss-deployer

. $SD_HOME/basic_confs
if [[ -f "$SD_HOME/dest_confs" ]]; then
  . $SD_HOME/dest_confs
  get_reality_dest_list="reality_dest_list=(\"\${reality_dest_list_${rtype}[@]}\")"
  eval $get_reality_dest_list
  get_ss_common_dest_list="ss_common_dest_list=(\"\${ss_common_dest_list_${rtype}[@]}\")"
  eval $get_ss_common_dest_list
  get_ss_tcp_dest_list="ss_tcp_dest_list=(\"\${ss_tcp_dest_list_${rtype}[@]}\")"
  eval $get_ss_tcp_dest_list
  get_ss_udp_dest_list="ss_udp_dest_list=(\"\${ss_udp_dest_list_${rtype}[@]}\")"
  eval $get_ss_udp_dest_list
fi
. $SD_HOME/mmp_ports
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

for_mmp_ports() {
  for port in "${mmp_ports[@]}"; do
    $1 $port
  done
}

# write
w() {
  echo "$2" >> $1
}

for_users() {
  local size=${#user_list[@]}
  for((ui=0;ui<${#user_list[@]};ui++)); do
    user=(${user_list[ui]})
    $1 ${user[0]} ${user[1]} ${user[2]} ${user[3]}
  done
}