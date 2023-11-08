for pid in $(pgrep -f traffics.sh); do
  kill -9 $pid
done
watch -n 0.5 bash /usr/ss-deployer/traffics.sh