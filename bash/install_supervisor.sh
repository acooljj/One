#!/bin/bash
funtion_centos6 (){
##Centos 6
yum -y install libevent memcached libmemcached libmemcached-devel gcc gcc-c++ nss zlib zlib-devel openssl openssl-devel python-devel --skip-broken
#升级Python
wget -P /tmp https://www.python.org/ftp/python/2.7.11/Python-2.7.11.tgz 
tar -zxvf  /tmp/Python-2.7.11.tgz -C  /tmp/
cd  /tmp/Python-2.7.11 && ./configure
make -j 4 && make install
mv -f /usr/bin/python /usr/bin/python2.6_bak
ln -s /usr/local/bin/python2.7 /usr/bin/python
#Install pip
curl https://bootstrap.pypa.io/get-pip.py | python
pip install --upgrade pip
#安装supervisor
pip install supervisor
dir=`find / -name echo_supervisord_conf`
$dir > /etc/supervisord.conf
echo -n "$(python -V)"
echo "$(pip -V | awk '{print $1,$2}')" 
echo "Supervisor $(supervisord -v)"
pwd
}

funtion_censot7 (){
##Centos 7
yum -y install libevent memcached libmemcached libmemcached-devel gcc gcc-c++ nss zlib zlib-devel openssl openssl-devel python-devel
#Install pip
curl https://bootstrap.pypa.io/get-pip.py | python
pip install --upgrade pip
#安装supervisor
pip install supervisor
dir=`find / -name echo_supervisord_conf`
$dir > /etc/supervisord.conf
echo -n "$(python -V)"
echo "$(pip -V | awk '{print $1,$2}')" 
echo "Supervisor $(supervisord -v)"
pwd
}


system_version=$(lsb_release -is)
system_version_num=$(uname -r | awk -F "." '{print $(NF-1)}')
case ${system_version} in
  CentOS)
    case ${system_version_num} in
      el7)
      funtion_censot7
      ;;
      el6)
      funtion_centos6
      ;;
      *)
      echo "check system in [ CentOS7 | CentOS6 ]";;
  *)
  echo "you system version is ${system_version}, check system in [ CentOS ]";;
esac

