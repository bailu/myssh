#/bin/bash

# 定义ssh config文件路径
DATA_FILE=~/.ssh/config

NAME_ARR=($(cat $DATA_FILE| grep '^Host' | awk '{print $2}'))

HOST_ARR=($(cat $DATA_FILE| grep 'HostName' | awk '{print $2}'))

COMMENT_ARR=($(cat $DATA_FILE|grep '^Host' -B 1 |awk '{print substr($0,3); getline; getline}'))

arr_len=${#NAME_ARR[@]}

for (( i = 0; i < $arr_len; i++ )); do
if [[ ${TYPE_ARR[$i]} -eq $1 ]]; then
  printf "%2d) %-20s %-12s %s\n" $i ${HOST_ARR[$i]} ${NAME_ARR[$i]} ${COMMENT_ARR[$i]}
fi
done

while true; do

   read -p "请输入你需要登录的服务器序号：" select

   if [[ ${arr_len} -gt $select ]] && [[ $select -ge 0 ]]; then

     break

   fi

done

echo 正在进入 ${NAME_ARR[$select]}（${HOST_ARR[$select]}）

ssh ${NAME_ARR[$select]}
