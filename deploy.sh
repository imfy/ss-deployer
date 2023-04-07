# 获取信息
read -p "本地ip（不输入则为127.0.0.1）：" ip
if [[ $ip == "" ]]; then
  ip=127.0.0.1
fi
read -p "聚合端口编号：" n
read -p "当前设备类型（前端1，落地2）：" type

# 修改mmp-go配置
port1=4${n}998
port2=4${n}999
sed -i "s/127.0.0.1/$ip/g" mmp-go/conf.json
sed -i "s/port1/$port1/g" mmp-go/conf.json
sed -i "s/port2/$port2/g" mmp-go/conf.json

# 修改naive配置
if [[ $type == 1 ]]; then
  echo "前端设备"
else
  rm -rf naive
fi

# 修改v2ray配置
rm -rf v2ray
if [[ $type == 1 ]]; then
  mv v2ray-front/* .
else
  mv v2ray-land/* .
fi
rm -rf v2ray-*
sed -i "s/127.0.0.1/$ip/g" v2ray/confs/inbounds.json


# 启动各项服务
chmod +x mmp-go/mmp-go
chmod +x naive/naive
chmod +x v2ray/v2ray
chmod +x *.sh
./mserver.sh
./vserver.sh
