[官网](http://www.openoffice.org/) |
[Dockerhub](https://hub.docker.com/r/rolesle/openoffice)

## build
进入到<version>目录

`docker build -t openoffice:<version> .`

## run

`docker run -d -p 8100:8100 openoffice:<version>`