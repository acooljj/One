#!/usr/bin/python
#python2
#Usage: discover tomcat_app
#Last Modified:
 
import subprocess
import json
args="for i in `ps -fC java | tail -n +2| awk '{print $2}'`;do ls -l /proc/$i/cwd | awk '{print $NF}'|awk -F '/' '{print $4}';done"
t=subprocess.Popen(args,shell=True,stdout=subprocess.PIPE).communicate()[0]
apps=[]
for app in t.split('\n'):
    if len(app) != 0:
        apps.append({'{#APP_NAME}':app})
print json.dumps({'data':apps},indent=4,separators=(',',':'))
