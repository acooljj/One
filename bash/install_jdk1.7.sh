#!/bin/bash
#!/usr/bin/expect
#授权
#chmod 755 /usr/java/jdk-6u30-linux-x64.bin
#切到安装目录
cd /usr/java/ || mkdir -p /usr/java/ && cd /usr/java/
#拷贝文件
cp /home/jdk-7u80-linux-x64.tar.gz /usr/java/
#执行安装
tar -zxvf jdk-7u80-linux-x64.tar.gz > /dev/null  << EOF
EOF
#增加环境变量
echo 'export JAVA_HOME=/usr/java/jdk1.7.0_80' >> /etc/profile
echo 'export JRE_HOME=/usr/java/jdk1.7.0_80/jre' >> /etc/profile
echo 'export JAVA_BIN=$PATH:/usr/java/jdk1.7.0_80/bin' >> /etc/profile
echo 'export CLASSPATH=./:/usr/java/jdk1.7.0_80/lib:/usr/java/jdk1.7.0_80/jre/lib' >> /etc/profile 
echo 'export PATH=$JAVA_HOME/bin:$PATH' >> /etc/profile
echo 'export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar' >> /etc/profile
echo 'export JAVA_HOME JAVA_BIN PATH CLASSPATH' >> /etc/profile
#保存环境变量
source /etc/profile