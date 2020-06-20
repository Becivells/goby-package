#!/bin/sh
# mysql数据库备???可以指定备份保留次数，指定不备份数据???
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH


TOKENFILE=/opt/goby-api/.dingtoken

# 判断文件是否存在
if [ ! -r ${TOKENFILE} ]; then
  echo "no token file or can not read"
  exit 0
fi

DINGTOKEN=`cat ${TOKENFILE}`

# 判断是否有值
if [ -z ${DINGTOKEN} ]; then
 echo "no token exit"
 exit 0
 fi

function SendMessageToDingding(){
    DINGTALK="https://oapi.dingtalk.com/robot/send?access_token=${DINGTOKEN}"
    # 发送钉钉消息
    curl "${DINGTALK}" -H 'Content-Type: application/json' -d "
    {
        \"actionCard\": {
            \"title\": \"$1\",
            \"text\": \"$2\",
            \"hideAvatar\": \"0\",
            \"btnOrientation\": \"0\",
            \"btns\": [
                {
                    \"title\": \"$1\",
                    \"actionURL\": \"\"
                }
            ]
        },
        \"msgtype\": \"actionCard\"
    }"
}

Subject="goby-api提示"

Body="goby-api已经重启"
SendMessageToDingding $Subject $Body
exit 0;

