server=/root/mmp-go/mmp-go
conf=/root/mmp-go/conf.json
log=/root/mmp-go/start.log

do_start() {
  nohup ${server} -conf ${conf} > ${log} &
}

do_stop() {
  for pid in $(pgrep -f mmp-go); do
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