#! /bin/bash

SD_HOME=/usr/ss-deployer

. $SD_HOME/generators/lib.sh

user_list=("${user_list_1[@]}" "${user_list_2[@]}")
banned_port_v4=()
banned_port_v6=()

allow_list_v4=()
allow_list_v6=()

get_icmp_prohibited() { if [ $1 == iptables ]; then echo icmp-host-prohibited; else echo icmp6-adm-prohibited; fi }

do_if_not_exist() {
    monitor=$(eval $1)
    if [ ${#monitor} == 0 ]; then
        eval $2
    fi
}

check_chains() {
    do_if_not_exist   "$1 -nvL | grep SSIN"            "$1 -N SSIN"
    do_if_not_exist   "$1 -nvL INPUT | grep SSIN"      "$1 -A INPUT -j SSIN"
    do_if_not_exist   "$1 -nvL | grep SSOUT"           "$1 -N SSOUT"
    do_if_not_exist   "$1 -nvL OUTPUT | grep SSOUT"    "$1 -A OUTPUT -j SSOUT"
}

accept_all() {
    do_if_not_exist    "$1 -nvL | grep 'tcp dpt:$2'"    "$1 -A SSIN -p tcp --dport $2"
    do_if_not_exist    "$1 -nvL | grep 'udp dpt:$2'"    "$1 -A SSIN -p udp --dport $2"
    do_if_not_exist    "$1 -nvL | grep 'tcp spt:$2'"    "$1 -A SSOUT -p tcp --sport $2"
    do_if_not_exist    "$1 -nvL | grep 'udp spt:$2'"    "$1 -A SSOUT -p udp --sport $2"
}

accept_ip() {
    do_if_not_exist    "$1 -nvL | grep '$2.*tcp dpt:$3'"    "$1 -A SSIN -p tcp -s $2 --dport $3 -j ACCEPT"
    do_if_not_exist    "$1 -nvL | grep '$2.*udp dpt:$3'"    "$1 -A SSIN -p udp -s $2 --dport $3 -j ACCEPT"
    do_if_not_exist    "$1 -nvL | grep '$2.*tcp spt:$3'"    "$1 -A SSOUT -p tcp -d $2 --sport $3 -j ACCEPT"
    do_if_not_exist    "$1 -nvL | grep '$2.*udp spt:$3'"    "$1 -A SSOUT -p udp -d $2 --sport $3 -j ACCEPT"
}

reject_all() {
    icmp_prohibited=$(get_icmp_prohibited $1)
    do_if_not_exist    "$1 -nvL | grep 'REJECT.*tcp dpt:$2'"    "$1 -A SSIN -p tcp --dport $2 -j REJECT --reject-with tcp-reset"
    do_if_not_exist    "$1 -nvL | grep 'REJECT.*udp dpt:$2'"    "$1 -A SSIN -p udp --dport $2 -j REJECT --reject-with $icmp_prohibited"
    do_if_not_exist    "$1 -nvL | grep 'REJECT.*tcp spt:$2'"    "$1 -A SSOUT -p tcp --sport $2 -j REJECT --reject-with tcp-reset"
    do_if_not_exist    "$1 -nvL | grep 'REJECT.*udp spt:$2'"    "$1 -A SSOUT -p udp --sport $2 -j REJECT --reject-with $icmp_prohibited"
}

set_rules() {
    cmd=$1
    port=$2
    if [ $cmd == iptables ]; then allow_list=($(echo ${allow_list_v4[@]})); else allow_list=($(echo ${allow_list_v6[@]})); fi
    if [ ${#allow_list[@]} -ne 0 ]; then
        for ip in ${allow_list[@]}; do
            accept_ip $cmd $ip $port
        done
        reject_all $cmd $port
    else
        accept_all $cmd $port
    fi
    echo "Add $port $cmd monitor."
    if [ ${#monitor} -ne 0 ]; then
        echo "No changes with $1."
    fi
}

if [[ $1 == "r" || $1 == "-r" ]]; then
  iptables -F
  ip6tables -F
fi

check_chains iptables
check_chains ip6tables

for port in ${banned_port_v4[@]}; do
  reject_all iptables $port
done
for port in ${banned_port_v6[@]}; do
  reject_all ip6tables $port
done
for line in "${user_list[@]}"; do
  user=($line)
  echo ${user[0]}
#  set_rules iptables $port
#  set_rules ip6tables $port 6
done