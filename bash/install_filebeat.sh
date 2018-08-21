#!/bin/bash
if [ "$USER" == "root" ]; then
 echo "filebeat installing... [rpm] "
 rpm -ivh https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-6.3.0-x86_64.rpm
 cp /etc/filebeat/filebeat.yml /etc/filebeat/filebeat.ybak
 if [ $? -eq 0 ];then filebeat version;else echo "filebeat install filed.";fi
else
 echo "User not is $USER, placse use root install."
 exit
fi

