#!/bin/bash
set -e 
curl https://raw.githubusercontent.com/mainiubaba/One/master/bash/init | bash
wget -O /tmp/check_system_version.sh https://raw.githubusercontent.com/mainiubaba/One/master/bash/check_system_version.sh --no-check-certificate
source /tmp/check_system_version.sh

wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key

fun_centos7 (){
  yum -y install jenkins fontconfig
  systemctl start jenkins
}

fun_centos6 (){
  yum -y install jenkins dejavu-sans-fonts
  service jenkins start
}

fun_jenkins (){
  echo "#Jenkins configure : /etc/sysconfig/jenkins"
  jenkins_pass=$(cat /var/lib/jenkins/secrets/initialAdminPassword)
  echo "#Jenkins AdminPassword : ${jenkins_pass}"
  MyIP=$(ip r | grep $(ip r | grep default |awk '{print $5}') | grep -v default | awk '{print $9}' | head -1)
  echo "#Serving HTTP on ${MyIP}  port 8080 ..."
}

case ${system_version} in
  CentOS)
    case ${system_version_num} in
      7)
      fun_centos7
      ;;
      6)
      fun_centos6
      ;;
      *)
      echo "check system in [ CentOS7 | CentOS6 ]";;
    esac
    fun_jenkins
    ;;
  *)
  echo "you system version is ${system_version}, check system in [ CentOS ]";;
esac
