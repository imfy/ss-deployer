#! /bin/bash

SD_HOME=/usr/ss-deployer

. $SD_HOME/generators/lib.sh


echo "generate xray/base.json"
cat>$SD_HOME/xray/confs/base.json<<EOF
{
  "api": {
    "tag": "api",
    "services": ["HandlerService", "LoggerService", "StatsService"]
  },
  "log": {
    "access": "/usr/ss-deployer/xray/log/access.log",
    "error": "/usr/ss-deployer/xray/log/error.log",
    "loglevel": "error",
    "dnsLog": false
  },
  "observatory": {
    "subjectSelector": [
      "obs"
    ]
  },
  "policy": {
    "levels": {
      "0": {
        "statsUserUplink": true,
        "statsUserDownlink": true
      }
    },
    "system": {
      "statsInboundUplink": true,
      "statsInboundDownlink": true,
      "statsOutboundUplink": true,
      "statsOutboundDownlink": true
    }
  },
  "stats": {}
}
EOF