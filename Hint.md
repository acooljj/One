# Hint leshi
crm软件：
> [百度百科](https://baike.baidu.com/item/crm%E8%BD%AF%E4%BB%B6)

> [salesforce](https://www.salesforce.com/cn/?ir=1)

---
Heroku是一个支持多种编程语言的云平台。
> [wiki](https://zh.wikipedia.org/w/index.php?title=Heroku&redirect=no)

---

Linux System Software 参考:
[Linux发行版软件](https://www.lulinux.com/archives/2787)

[为Linux Mint设置为雅黑字体](https://blog.csdn.net/wangrui1573/article/details/81973919)

[安装Linux Mint 18.2后要做的20件事](https://www.cnblogs.com/xcb0730/p/9286708.html)

[使用 Linux Mint 作为主要操作系统的一些个人常用软件](https://www.cnblogs.com/xiaoshen666/p/10916857.html)

[linux常用的几个软件](https://www.cnblogs.com/dcb3688/p/4607976.html)


---
Linux下工具的安装
1 聊天工具， 微信; qq
2 ssh工具，Remmina
3 浏览器， chrome; Firefox
4 翻墙工具，
5 文本编辑器， atom; vsCode; Unity
6 wps， 自带的; wps
7 vpn，openvpn; esayconnect
8 pdf查看器， okular
9 远程工具，teamviewer
10 py工具， pycharm; pip2; pip3; py2; py3
11 版本控制客户端， git;svn;RapidSVN
12 数据库客户端， dbeaver
13 打包工具， tar;zip
14 下载工具, wget
15 局域网端口侦测工具, zenmap
16 其他的东西, 下拉式终端tilda; HTTP 协议文件共享服务Chfs

安装记录：
更新: apt-get update
解决依赖: sudo apt-get --fix-broken -y install
1. 聊天工具
QQ，微信: 需要安装[deepin-wine环境](https://github.com/wszqkzqk/deepin-wine-ubuntu);
然后去[Deepin-wine 容器的存档](https://gitee.com/wszqkzqk/deepin-wine-containers-for-ubuntu/);
下载对应的包

2. ssh工具
Remmina: `sudo apt-add-repository ppa:remmina-ppa-team/remmina-next && sudo apt update && sudo apt install -y remmina remmina-plugin-rdp remmina-plugin-secret remmina-plugin-spice`  --缺依赖包，没成功

3. 浏览器
chrome: `sudo apt-get install chromium-browser`
Firefox: Mint系统自带

4. 翻墙工具


5. 文本编辑器
atom: `wget https://github.com/atom/atom/releases/download/v1.38.1/atom-amd64.deb && sudo dpkg -i atom-amd64.deb`
vsCode: `wget https://vscode.cdn.azure.cn/stable/c7d83e57cd18f18026a8162d042843bda1bcf21f/code_1.35.1-1560350270_amd64.deb && sudo dpkg -i code_1.35.1-1560350270_amd64.deb`
Unity: `wget https://public-cdn.cloud.unity3d.com/hub/prod/UnityHubSetup.AppImage && chmod +x UnityHubSetup.AppImage && ./UnityHubSetup.AppImage`,启动 Unity Hub 后，它会要求你使用 Unity ID 登录（或注册）以激活许可证。使用 Unity ID 登录后，进入 “Installs” 选项（如上图所示）并添加所需的版本/组件。

6. wps
LibreOffice: Mint系统自带
wps: `wget https://wdl1.cache.wps.cn/wps/download/ep/Linux2019/8392/wps-office_11.1.0.8392_amd64.deb && sudo dpkg -i wps-office_11.1.0.8392_amd64.deb`

7. vpn
openvpn: [官网下载客户端](https://www.techspot.com/downloads/5182-openvpn.html) `wget https://files02.tchspt.com/storage2/temp/openvpn-2.4.7.tar.gz && sudo apt install -y openssl libssl-dev net-tools liblzo2-dev libpam0g-dev && tar -zxf openvpn-2.4.7.tar.gz && cd openvpn-2.4.7 && ./configure && make && sudo make install`
esayconnect: 待测试

8. pdf查看器
okular: `sudo apt-get install okular`

9. 远程工具
teamviewer: `wget https://download.teamviewer.com/download/linux/teamviewer_amd64.deb && sudo dpkg -i teamviewer_amd64.deb`

10. py工具,py环境
pycharm： `wget https://download.jetbrains.8686c.com/python/pycharm-community-2019.1.3.tar.gz && sudo tar -zxf pycharm-community-2019.1.3.tar.gz -C /usr/local/share && ls -n /usr/local/share/pycharm-community-2019.1.3/bin/pycharm.sh ~/桌面`，运行时选运行
py2: Mint系统自带, python -V
pip2: Mint系统自带, pip2 -V
py3: Mint系统自带, python3 -V
pip3: `sudo apt-get install -y python3-pip`， pip3 -V

11. 版本控制客户端
git: `sudo apt install -y git`
svn: `sudo apt install -y subversion`
RapidSVN: `sudo apt-get install -y rapidsvn meld`

12. 数据库客户端
dbeaver: `wget https://github.com/dbeaver/dbeaver/releases/download/6.1.0/dbeaver-ce_6.1.0_amd64.deb && sudo dpkg -i dbeaver-ce_6.1.0_amd64.deb`

13. 打包工具
tar: Mint系统自带
zip: Mint系统自带

14. 下载工具
wget: Mint系统自带

15. 局域网端口侦测工具
zenmap: `sudo apt install -y zenmap`

16. 其他的东西,
下拉式终端tilda: `sudo apt-get install -y tilda`
HTTP 协议文件共享服务Chfs: `wget https://files-cdn.cnblogs.com/files/dcb3688/chfs-linux-amd64-1.4.zip && unzip chfs-linux-amd64-1.4.zip && chmod +x chfs && ./chfs --port 8080 --path /home/lshi/下载`


常用工具记录
(链接到下载/软件主界面)
linux-mint(ubuntu)
下载工具: uget
笔记工具: VS code,atom
文件夹管理工具:
搜索工具:
Py工具:
桌面壁纸工具
cmd:
打包工具: tar，zip
数据库工具:
浏览器: chromium-brower
wps: 自带，测试跟win的兼容性
ssh客户端: easyssh
, storm
