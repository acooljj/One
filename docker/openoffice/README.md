[Apache OpenOffice 官网](http://www.openoffice.org/) 

DockerHub地址: [rolesle/openoffice](https://hub.docker.com/r/rolesle/openoffice)

**build** *dockerhub的镜像采用离线方式构建,详情参考对应版本说明文档*

进入到\<version>目录

`docker build -t openoffice:<version> .`

**run**

`docker run -d -p 8100:8100 openoffice:<version>`

**docker-compose**

```
version: '3'

services:
  openoffice:
    container_name: openoffice
    image: rolesle/openoffice:4.1.7
    # 解决转PDF中文乱码问题
    #volume:
    #  - /path/to/fonts:/opt/openoffice4/share/fonts/truetype
    ports:
      - 8100:8100
```

**说明**
- word转PDF中文乱码问题，因为中文字体种类众多，所以需要手动挂载中文字体目录到office字体目录



---
- 2019年11月8日: 修复只能本地连接的问题
- 2019年11月22日: 修复word文件转PDF中文乱码问题