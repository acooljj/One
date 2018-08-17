#!/bin/bash
httpd=2.2.34
apr=1.6.3
apr_util=1.6.1
pcre=8.41
make_num=$(grep "processor" /proc/cpuinfo  -c)


cmake_install (){
make -j ${make_num}
make install
echo -n "cd $(pwd)"
cd /tmp
}

init (){
curl https://raw.githubusercontent.com/mainiubaba/One/master/bash/init_apache | bash
}

awget (){
wget -c -q -O httpd-${httpd}.tar.gz http://archive.apache.org/dist/httpd/httpd-${httpd}.tar.gz
wget -c -q -O apr-${apr}.tar.gz http://mirrors.shu.edu.cn/apache//apr/apr-${apr}.tar.gz
wget -c -q -O apr-util-${apr_util}.tar.gz http://mirrors.shu.edu.cn/apache//apr/apr-util-${apr_util}.tar.gz
wget -c -q -O pcre-${pcre}.tar.gz https://ftp.pcre.org/pub/pcre/pcre-${pcre}.tar.gz
}

install_apr (){
#安装apr
if [ ! -d /usr/local/apr ]; then
tar -zxf apr-${apr}.tar.gz
cd apr-${apr}
./configure --prefix=/usr/local/apr
cmake_install
else
 echo "apr exists..."
fi
}

install_apr_util (){
#安装apr-util
if [ ! -d /usr/local/apr-util ]; then
tar -zxf apr-util-${apr_util}.tar.gz
cd apr-util-${apr_util}
./configure --prefix=/usr/local/apr-util --with-apr=/usr/local/apr
cmake_install
else
 echo "apr-util exists..."
fi
}

install_pcre (){
#安装pcre
if [ ! -d /usr/local/pcre ]; then
tar -zxf pcre-${pcre}.tar.gz
cd pcre-${pcre}
./configure --prefix=/usr/local/pcre
cmake_install
else
 echo "pcre exists..."
fi
}

install_apache (){
#安装apache
if [ ! -d /home/apache2 ]; then
  tar -zxf httpd-${httpd}.tar.gz
  cd httpd-${httpd}
  if [ "${httpd}" == "2.2.34" ]; then
    ./configure --prefix=/home/apache2  --enable-cgi --enable-cgid --enable-ssl --enable-rewrite
  else
    ./configure --prefix=/home/apache2  --enable-cgi --enable-cgid --enable-ssl --enable-rewrite --with-pcre=/usr/local/pcre --with-apr=/usr/local/apr  --with-apr-util=/usr/local/apr-util --enable-modules=most --enable-mods-shared=most  --enable-mpms-shared=all --with-mpm=event --with-mpm=event --enable-proxy --enable-proxy-fcgi --enable-expires --enable-deflate
  fi
    cmake_install
    ln -s /lib64/libexpat.so.1 /usr/lib64/libexpat.so.0
  else
   echo "apache exists..."
fi
}

install_modsecurity (){
#安装modsecurity
#https://github.com/SpiderLabs/ModSecurity/wiki/Reference-Manual-%28v2.x%29#Installation_for_Apache
git clone git://github.com/SpiderLabs/ModSecurity.git
cd ModSecurity
./autogen.sh #libtoolize: command not found -- should install libtool*
./configure --with-apxs=/home/apache2/bin/apxs
cmake_install
}

check_security (){
#check
line_num=$(grep -n "ServerName" /home/apache2/conf/httpd.conf | awk -F ':' '{print $1}' | head -1)
grep '^ServerName 0.0.0.0' /home/apache2/conf/httpd.conf || sed -i "${line_num}a\ServerName 0.0.0.0" /home/apache2/conf/httpd.conf
/home/apache2/bin/apachectl configtest
if [ $? -eq '0' ];then :; else echo "apachectl check filed";exit 1;fi

echo "/home/apache2/modules/ : "
if [ "${httpd}" == "2.2.34" ]; then
  if [ -f /home/apache2/modules/mod_security.so ];then echo mod_security.so;else echo "mod_security2.so File not exists";fi
else
  if [ -f /home/apache2/modules/mod_security2.so ];then echo mod_security2.so;else echo "mod_security2.so File not exists";fi
fi
cp ModSecurity/modsecurity.conf-recommended  /home/apache2/conf/modsecurity.conf
cd /home/apache2/conf
echo "cd $(pwd)"
grep '#必须在ModSecurity之前加载libxml2和lua5.1' /home/apache2/conf/httpd.conf || echo '#必须在ModSecurity之前加载libxml2和lua5.1' >> /home/apache2/conf/httpd.conf
grep 'LoadFile /usr/lib64/libxml2.so' /home/apache2/conf/httpd.conf || echo 'LoadFile /usr/lib64/libxml2.so' >> /home/apache2/conf/httpd.conf
grep 'LoadFile /usr/lib64/liblua-5.1.so' /home/apache2/conf/httpd.conf || echo 'LoadFile /usr/lib64/liblua-5.1.so' >> /home/apache2/conf/httpd.conf
grep '#加载ModSecurity模块' /home/apache2/conf/httpd.conf || echo '#加载ModSecurity模块' >> /home/apache2/conf/httpd.conf
grep 'LoadModule security2_module modules/mod_security2.so' /home/apache2/conf/httpd.conf || echo 'LoadModule security2_module modules/mod_security2.so' >> /home/apache2/conf/httpd.conf
sed -i s/^SecUnicodeMapFile/#SecUnicodeMapFile/g modsecurity.conf
/home/apache2/bin/apachectl configtest
if [ $? -eq '0' ];then /home/apache2/bin/httpd -V; else echo "apachectl check filed";exit 1;fi
}

install_apache2.4 (){
cd /tmp
init
awget
install_apr
install_apr_util
install_pcre
install_apache
install_modsecurity
check_security
}

install_apache2.2 (){
cd /tmp
init
awget
install_apr
install_apr_util
install_pcre
install_apache
install_modsecurity
}

if [ "${httpd}" == "2.2.34" ]; then
  install_apache2.2
else
  install_apache2.4
fi
