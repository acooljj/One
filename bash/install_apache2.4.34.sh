#!/bin/bash
httpd=2.4.34
apr=1.6.3
apr_util=1.6.1
pcre=8.41
make_num=$(grep "processor" /proc/cpuinfo  -c)


cmake_install (){
make -j ${make_num}
make install
}

init (){
curl https://raw.githubusercontent.com/mainiubaba/One/master/bash/init_apache | bash
}

awget (){
wget -c -q -O httpd-${httpd}.tar.bz2 http://mirrors.shu.edu.cn/apache//httpd/httpd-${httpd}.tar.bz2
wget -c -q -O apr-${apr}.tar.gz http://mirrors.shu.edu.cn/apache//apr/apr-${apr}.tar.gz
wget -c -q -O apr-util-${apr_util}.tar.gz http://mirrors.shu.edu.cn/apache//apr/apr-util-${apr_util}.tar.gz
wget -c -q -O pcre-${pcre}.tar.gz https://ftp.pcre.org/pub/pcre/pcre-${pcre}.tar.gz
}

install_apr (){
#安装apr
tar -zxf apr-${apr}.tar.gz
cd apr-${apr}
./configure --prefix=/usr/local/apr
cmake_install
}

install_apr_util (){
#安装apr-util
tar -zxf apr-util-${apr_util}.tar.gz
cd apr-util-${apr_util}
./configure --prefix=/usr/local/apr-util --with-apr=/usr/local/apr
cmake_install
}

install_pcre (){
#安装pcre
tar -zxf pcre-${pcre}.tar.gz
cd pcre-${pcre}
./configure --prefix=/usr/local/pcre 
cmake_install
}

install_apache (){
#安装apache
tar -jxf httpd-${httpd}.tar.bz2
cd httpd-${httpd}
./configure --prefix=/home/apache2  --enable-cgi --enable-cgid --enable-ssl --enable-rewrite --with-pcre=/usr/local/pcre --with-apr=/usr/local/apr  --with-apr-util=/usr/local/apr-util --enable-modules=most --enable-mods-shared=most  --enable-mpms-shared=all --with-mpm=event --with-mpm=event --enable-proxy --enable-proxy-fcgi --enable-expires --enable-deflate
cmake_install
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
ls /home/apache2/modules/
/home/apache2/bin/apachectl configtest
if [ $? -eq '0' ];then countinue; else echo "apachectl check filed";exit 1;fi
cp ModSecurity/modsecurity.conf-recommended  /home/apache2/conf/modsecurity.conf
cat >> /home/apache2/conf/httpd.conf << EOF
#必须在ModSecurity之前加载libxml2和lua5.1
LoadFile /usr/lib64/libxml2.so
LoadFile /usr/lib64/liblua-5.1.so
#加载ModSecurity模块
LoadModule security2_module modules/mod_security2.so
EOF

cd /home/apache2
sed -i s/ServerName/ServerName 0.0.0.0/g httpd.conf
sed -i s/SecUnicodeMapFile/#SecUnicodeMapFile/g modsecurity.conf
/home/apache2/bin/apachectl configtest
./bin/apachectl/httpd -V
}

cd /tmp
init
awget
install_apr
install_apr_util
install_pcre
install_apache
install_modsecurity
check_security
