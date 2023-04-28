xserver=/root/xray/xray
xconfs=/root/xray/confs
xlogs=/root/xray/log

do_start() {
	nohup /root/xray/xray run -confdir /root/xray/confs > /root/xray/log/start.log &
}

do_stop() {
  for pid in $(pgrep -f xray); do
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