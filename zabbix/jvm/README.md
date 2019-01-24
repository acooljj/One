# template
jdk: 1.7,1.8
jvm分区:
  新生代
    伊甸园
    幸存区0
    幸存区1
  老生代
  永生代/元空间  (1.7/1.8)
.获取当前机器正在运行的java程序，截取出一个或多个服务名
..根据服务名查到PID，截取jstat [-gc|-gcutil] 输出结果
...配置文件定义服务名称的key和监控项的key
....模板自动发现，记录每个分区的总大小，已使用大小，使用百分比，GC回收次数，总回收次数，回收使用的时间，回收总时间，新生代回收次数，新生代回收使用时间,(java进程启动时间，tomat版本，java版本，进程启动用户，)

1.zabbix_discover_jvm.py
path:/etc/zabbix/zabbix_agentd.d
2.zabbix_app_status.sh
path:/etc/zabbix/scripts
3.zabbix_discover_jvm.conf
path:
4.
zabbix3.0监控jvm模板,web端导入模板用
