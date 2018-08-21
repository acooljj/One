#!/bin/bash
elk_user=elk
useradd (){
  useradd ${elk_user}
  echo "123qwe!@#QWE" | passwd ${elk_user} --stdin
  grep "${elk_user} ALL=(ALL) NOPASSWD: ALL" /etc/sudoers || echo "${elk_user} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
  grep "Defaults: ${elk_user}  !requiretty" /etc/sudoers || echo "Defaults: ${elk_user}  !requiretty" >> /etc/sudoers
}

install_logstash (){
  if [ ! -d /home/${elk_user}/logstash-6.3.0 ]; then
    wget -q -O /tmp/logstash-6.3.0.tar.gz https://artifacts.elastic.co/downloads/logstash/logstash-6.3.0.tar.gz
    tar -zxf /tmp/logstash-6.3.0.tar.gz -C /home/${elk_user}
    chown -R ${elk_user}.${elk_user} /home/${elk_user}
  else
    echo "Directory /home/${elk_user}/logstash-6.3.0 exists"
  fi
}

if [ 0 -eq $(grep ${elk_user} /etc/passwd | wc -l ) ]; then
  useradd
  create elk_user ${elk_user}
else 
  elk_user ${elk_user} exists
fi
install_logstash
