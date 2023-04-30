#! /bin/bash

SD_HOME=/usr/ss-deployer
IP_FILE=$SD_HOME/ip
MMP_PORTS_FILE=$SD_HOME/mmp_ports

# 创建配置目录
if [[ ! -d $SD_HOME ]]; then mkdir $SD_HOME; fi

# 选择模式
read -p "新装或更新配置？（新装1；更新配置2。不输入默认2）：" mode
if [[ $mode == "" ]]; then mode=2; fi

# 配置ip
read -p "本地ip（不输入则为127.0.0.1）：" ip
if [[ $ip == "" ]]; then ip=127.0.0.1; fi
echo $ip > $IP_FILE

# 配置mmp端口
read -p "聚合端口编号（不输入则为1，即41998和41999）：" n
if [[ $n == "" ]]; then n=1; fi
echo "mmp_ports=(4${n}998 4${n}999)" > $MMP_PORTS_FILE

# 配置ss端口
if [[ -f user_confs ]]; then mv -f user_confs $SD_HOME/user_confs; fi

# 配置线路
if [[ -f dest_confs ]]; then mv -f dest_confs $SD_HOME/dest_confs; fi

# 配置设备类型
read -p "当前设备类型（前置1；落地2。不输入默认2）：" type
if [[ $type == "" ]]; then type=2; fi

# 执行安装
if [[ $mode == 1 ]]; then
  apt install -y git
  rm -rf ss-deployer
  git clone https://github.com/imfy/ss-deployer.git
  rm -rf ss-deployer/.git
  rm -rf ss-deployer/deploy.sh
  rm -rf ss-deployer/README.md
  if [[ -d mmp-go ]]; then rm -rf mmp-go; fi
  if [[ -d xray ]]; then rm -rf xray; fi
  if [[ -d naive ]]; then rm -rf naive; fi
  mv -f ss-deployer/* .
  rm -rf ss-deployer
  mkdir xray/log
  if [[ $type == 2 ]]; then
    read -p "是否安装warp以提供ipv6解锁能力（安装1；不安装2。不输入默认2）：" warp
    if [[ $warp == "" ]]; then warp=2; fi
    if [[ $warp == 1 ]]; then
      apt install -y curl
      wget -N https://raw.githubusercontent.com/fscarmen/warp/main/menu.sh && bash menu.sh
      bash menu.sh
    fi
  fi
fi

chmod +x *.sh

# 生成配置文件
if [[ $type == 1 ]]; then
  if [[ ! -d $SD_HOME/generators ]]; then mkdir $SD_HOME/generators; fi
  mv -f generators/* $SD_HOME/generators
  rm -rf generators
  ./gen_configs.sh 1
else
  rm -rf naive
  rm -rf nserver.sh
  ./gen_configs.sh 2
fi
