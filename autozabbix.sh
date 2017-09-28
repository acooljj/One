#!/bin/bash
yum install -y gcc curl
mkdir /home/zabbix
cd /home/zabbix
wget http://jaist.dl.sourceforge.net/project/zabbix/ZABBIX%20Latest%20Stable/2.2.5/zabbix-2.2.5.tar.gz
tar zvxf zabbix-2.2.5.tar.gz
cd zabbix-2.2.5
./configure --prefix=/usr/local/zabbix_agent   --enable-agent
make install
IP="`ifconfig | grep '\([[:digit:]]\{1,3\}\.\)\{3\}[[:digit:]]\{1,3\}' --color=auto -o | sed -e '2,5d'`"
echo "Server=192.168.9.73" > /usr/local/zabbix_agent/etc/zabbix_agentd.conf
echo "Hostname=${IP}" >> /usr/local/zabbix_agent/etc/zabbix_agentd.conf
echo "UnsafeUserParameters=1" >> /usr/local/zabbix_agent/etc/zabbix_agentd.conf
echo "EnableRemoteCommands=1" >> /usr/local/zabbix_agent/etc/zabbix_agentd.conf
echo "UserParameter=tcpportlisten,/usr/local/zabbix_agent/sbin/discovertcpport.sh "$1"" >> /usr/local/zabbix_agent/etc/zabbix_agentd.conf
iptables -I INPUT -p tcp --dport 10050:10051 -j ACCEPT
iptables -I INPUT -p udp --dport 10050:10051 -j ACCEPT
service iptables save
cp /usr/local/zabbix_agent/sbin/zabbix_agentd /etc/init.d/
chmod +x /etc/init.d/zabbix_agentd
service zabbix_agentd start
echo "/etc/init.d/zabbix_agentd start" >> /etc/rc.local
echo "zabbix_agentd already install."
ps ax|grep zabbix_agentd
less /usr/local/zabbix_agent/etc/zabbix_agentd.conf
exit
fi
