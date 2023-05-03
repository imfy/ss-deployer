#! /bin/bash

SD_HOME=/usr/ss-deployer

BASIC_CONF=$SD_HOME/basic_confs
GENERATORS_DIR=$SD_HOME/generators
MMP_BIN=/usr/bin/mmp-go
MMP_DIR=$SD_HOME/mmp-go
MMP_PORTS_FILE=$SD_HOME/mmp_ports
PR_BIN=/usr/bin/port-rules.sh
XRAY_BIN=/usr/bin/xray
XRAY_DIR=$SD_HOME/xray

# 创建配置目录
if [[ ! -d $SD_HOME ]]; then mkdir $SD_HOME; fi
rm -rf $BASIC_CONF

# 选择模式
read -p "新装或更新配置？（新装1；更新配置2。不输入默认2）：" mode
if [[ $mode == "" ]]; then mode=2; fi

# 配置ip
read -p "本地ip（不输入则为127.0.0.1）：" ip
if [[ $ip == "" ]]; then ip=127.0.0.1; fi
echo "ip=$ip" >> $BASIC_CONF

# 配置mmp端口
read -p "聚合端口编号（不输入则为1，即41998和41999）：" rtype
if [[ $rtype == "" ]]; then rtype=1; fi
echo "mmp_ports=(4${rtype}998 4${rtype}999)" > $MMP_PORTS_FILE
echo "rtype=$rtype" >> $BASIC_CONF

# 配置ss端口
if [[ -f user_confs ]]; then mv -f user_confs $SD_HOME/user_confs; fi

# 配置线路
if [[ -f dest_confs ]]; then mv -f dest_confs $SD_HOME/dest_confs; fi

# 配置设备类型
read -p "当前设备类型（前置1；落地2。不输入默认2）：" dtype
if [[ $dtype == "" ]]; then dtype=2; fi
echo "dtype=$dtype" >> $BASIC_CONF

# 执行安装
if [[ $mode == 1 ]]; then
  # 安装依赖
  apt install -y git

  # clone项目
  rm -rf ss-deployer
  git clone https://github.com/imfy/ss-deployer.git

  # 移除无用文件
  rm -rf ss-deployer/.git
  rm -rf ss-deployer/deploy.sh
  rm -rf ss-deployer/README.md

  # 移动mmp-go
  mv -f ss-deployer/mmp-go/mmp-go $MMP_BIN
  chmod +x $MMP_BIN
  if [[ -d $MMP_DIR ]]; then rm -rf $MMP_DIR; fi
  mkdir $MMP_DIR

  # 移动xray
  mv -f ss-deployer/xray/xray $XRAY_BIN
  mv -f ss-deployer/xray/*.dat /usr/bin
  chmod +x $XRAY_BIN
  if [[ -d $XRAY_DIR ]]; then rm -rf $XRAY_DIR; fi
  mkdir $XRAY_DIR
  mkdir $XRAY_DIR/log
  mv -f ss-deployer/xray/* $XRAY_DIR

  # 移动generators
  if [[ -d $GENERATORS_DIR ]]; then rm -rf $GENERATORS_DIR; fi
  mkdir $GENERATORS_DIR
  mv -f ss-deployer/generators/* $GENERATORS_DIR

  # 移动port-rules
  mv -f ss-deployer/port-rules.sh $PR_BIN
  chmod +x $PR_BIN

  # 移动system
  mv -f ss-deployer/systemd/* /lib/systemd/system

  # 剩余文件迁到root文件夹下
  mv -f ss-deployer/gen_configs.sh /root/gen_configs.sh
  mv -f ss-deployer/watch-traffics.sh /root/watch-traffics.sh
  rm -rf ss-deployer

  # 安装warp
  if [[ $dtype == 2 ]]; then
    read -p "是否安装warp以提供ipv6解锁能力（安装1；不安装2。不输入默认2）：" warp
    if [[ $warp == "" ]]; then warp=2; fi
    if [[ $warp == 1 ]]; then
      wget https://raw.githubusercontent.com/fscarmen/warp/main/menu.sh && bash menu.sh
      bash menu.sh
    fi
  fi
fi

chmod +x *.sh

# 生成配置文件
./gen_configs.sh
