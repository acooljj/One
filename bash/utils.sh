#!/bin/bash
#all server funtion
#Use:. /path/to/utils.sh

proFile=/etc/proFile
goPath=/usr/local
goVersion=1.11.1
goDownloadPath=https://dl.google.com/go/go${goVersion}.linux-amd64.tar.gz
glicVersion=2.16.0
glicPortsVersion=2.16.0


#System
countCpu (){
  cat /proc/cpuinfo | grep -c processor
}

judgeDirectory (){
  dName=${1}
  [[ -d ${dName} ]] || mkdir -pv ${dName}
}

#Packages server
centos7YumApache (){
  #centos 7
  yum -y install wget tree vim lrzsz mlocate gcc gcc-c++ make cmake zlib zlib-devel openssl openssl-devel nss telnet nmap iotop strace net-tools lsof git rsync gdb bzip2 expat-devel libtool libxml2-devel libcurl-devel
}

#Path
centosInstallGo (){
  echo "Installing Go..."
  wget -N ${goDownloadPath} 2> /dev/null
  [[ -d ${goPath}/go ]] || sudo tar -C ${goPath} -zxf go${goVersion}.linux-amd64.tar.gz
  grep '#go path' ${proFile} > /dev/null|| echo '#go path' >> ${proFile}
  grep "export GOPATH=${goPath}/go"  ${proFile} > /dev/null|| echo "export GOPATH=${goPath}/go" >> ${proFile}
  grep 'export PATH=$PATH:$GOPATH/bin' ${proFile} > /dev/null|| echo 'export PATH=$PATH:$GOPATH/bin' >> ${proFile}
  source ${proFile}
  go version
  echo -e "...\ngo install successful."
}

centosinstallGlibc (){
  glibcpath=/tmp/glibc
  judgeDirectory ${glibcpath}
  cd ${glibcpath}
  wget -N http://ftp.gnu.org/gnu/glibc/glibc-${glicVersion}.tar.xz 2>/dev/null
  wget -N http://ftp.gnu.org/gnu/glibc/glibc-ports-${glicPortsVersion}.tar.xz 2>/dev/null
  tar -Jxf glibc-${glicVersion}.tar.xz
  tar -Jxf glibc-ports-${glicPortsVersion}.tar.xz
  mv glibc-ports-${glicPortsVersion} glibc-${glicVersion}/glibc-ports
  mkdir -p glibc-${glicVersion}/build
  cd glibc-${glicVersion}/build
  ../configure --prefix=/usr --disable-profile --enable-add-ons --with-headers=/usr/include --with-binutils=/usr/bin
  make -j countCpu
  make install
  ls ${glibcpath}
}

