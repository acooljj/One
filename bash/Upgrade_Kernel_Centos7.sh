#!/bin/bash
# Centos 7升级内核(3.10 -> latest)

# 更新仓库
yum -y update
# 启用 ELRepo 仓库
rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-2.el7.elrepo.noarch.rpm
# 安装新内核
yum --enablerepo=elrepo-kernel install kernel-ml
# 设置grub2
awk -F\' '$1=="menuentry " {print i++ " : " $2}' /etc/grub2.cfg
grub2-set-default 0
grep "GRUB_DEFAULT=0" /etc/default/grub || sed -i '$a\GRUB_DEFAULT=0' /etc/default/grub
# 生成 grub 配置文件
grub2-mkconfig -o /boot/grub2/grub.cfg
# 重启
reboot
