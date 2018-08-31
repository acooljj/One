#!/bin/bash
set -e
yum -y install wget
#安装node版本
node_version=8.11.4
#安装node路径
node_home_path=/usr/local

function node_install (){
  echo "Install Node..."
  if [ ! -d ${node_home_path}/node ];then
    if [ ! -f /tmp/node-v${node_version}-linux-x64.tar.xz ];then
    wget -O /tmp/node-v${node_version}-linux-x64.tar.xz https://nodejs.org/dist/v${node_version}/node-v${node_version}-linux-x64.tar.xz;fi
    xz -d /tmp/node-v${node_version}-linux-x64.tar.xz
    tar -xf /tmp/node-v${node_version}-linux-x64.tar
    mv node-v${node_version}-linux-x64/ ${node_home_path}/node
  else
    grep "export NODE_HOME=${node_home_path}/node" /etc/profile || echo "export NODE_HOME=${node_home_path}/node" >> /etc/profile
    grep 'export PATH=$NODE_HOME/bin:$PATH' /etc/profile ||  echo 'export PATH=$NODE_HOME/bin:$PATH' >> /etc/profile
    source /etc/profile
    echo "node : $(node -v)"
    echo "npm : $(npm -v)"
    echo "Node Install Finished: SUCCESS"
  fi
}

function Hubot_install (){
  echo "Install Hubot..."
  #npm install -g yo generator-hubot
  if [ $USER == "root" ];then
    chmod g+rwx -R /root /root/.config 
    chmod 775 -R /root/.config/configstore/
    chmod 775 -R /root/.npm/_cacache/
    chmod 775 -R /root/.npm/_locks
  else
    :
  fi
  node_data=${node_home_path}/node/node_$USER_$(date '+%F')
  mkdir ${node_data}
  chmod g+rwx ${node_data}
  cd ${node_data}
  echo "++根据提示填写相关信息: [Email, HuhotName, Bs]"
  yo hubot --adapter=slack
  echo "Hubot Install Finished: SUCCESS"
  sleep 1
  echo "++输入机器人连接Slack的Token："
  echo "++Ps: [登陆slack，添加app，进入app商店搜索hubot，然后安装，如果已经安装就是可以添加机器人，下滑有这个机器人的Token值]"
  while true;
  do
   read -p "++Token :" Slack_Token
   Zoo=$(echo ${Slack_Token} | wc -L) #55
   if [ ${Zoo} != 55 ];then break;fi
   One=$(echo ${Slack_Token} | awk -F "-" '{print $1}' | wc -L) #4
   Two=$(echo ${Slack_Token} | awk -F "-" '{print $2}' | wc -L) #12
   Three=$(echo ${Slack_Token} | awk -F "-" '{print $3}' | wc -L) #12
   Four=$(echo ${Slack_Token} | awk -F "-" '{print $4}' | wc -L) #24
   if [ ! -z ${Slack_Token} ];then
      if [ ${Zoo} -eq 55  ];then
        if [ ${One} -eq 4 ];then
          if [ ${Two} -eq 12 ];then
            if [ ${Three} -eq 12 ];then
              if [ ${Four} -eq 24 ];then echo "Slack_Token length is 55"; break;fi ;fi ;fi ;fi ;fi
   else echo -n "Placse Input Token or Exit(Ctrl+c)";fi
  done
  grep "export HUBOT_SLACK_TOKEN=" /etc/profile || echo "export HUBOT_SLACK_TOKEN=${Slack_Token}" >> /etc/profile
  source /etc/profile
  echo "Start Hubot_slack..."
  nohup hubot --adapter slack 2&>1 >> /dev/null &
}
node_install
Hubot_install

