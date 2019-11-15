#!/usr/bin/env bash
set -ex
yum -y install ruby gem wget unzip
wget -Ncq https://github.com/busyloop/lolcat/archive/master.zip
set +ex
yes | unzip master.zip
cd lolcat-master
echo "Install lolcat..."
gem install lolcat
echo
echo "lolcat version:"
$(whereis lolcat | awk '{print $2}') --version