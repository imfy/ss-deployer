#! /bin/bash

SD_HOME=/usr/ss-deployer

# 创建mmp-go的config.json
bash $SD_HOME/generators/gen_mmp_conf.sh

# 创建inbounds.json
bash $SD_HOME/generators/gen_inbounds.sh

if [[ $1 == "1" ]]; then
  # 创建outbounds.json
  bash $SD_HOME/generators/gen_outbounds.sh
  # 创建routing.json
  bash $SD_HOME/generators/gen_routings.sh
fi

## 启动各项服务
systemctl daemon-reload  # 重新载入服务
systemctl enable mmp-go
systemctl enable port-rules
systemctl enable xray
service mmp-go start
service port-rules start
service xray start
