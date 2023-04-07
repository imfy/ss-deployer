xserver=/root/v2ray/v2ray
xconfs=/root/v2ray/confs
xlogs=/root/v2ray/log

do_start() {
	nohup /root/v2ray/v2ray run -confdir /root/v2ray/confs > /root/v2ray/log/start.log &
}

do_stop() {
  for pid in $(pgrep -f v2ray); do
    kill -9 $pid
    echo $pid" Stoped."
  done
}

do_restart() {
  do_stop
  sleep 0.5
  do_start
}

do_restart