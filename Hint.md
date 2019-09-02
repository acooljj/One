# Hint leshi
crm软件：
> [百度百科](https://baike.baidu.com/item/crm%E8%BD%AF%E4%BB%B6)

> [salesforce](https://www.salesforce.com/cn/?ir=1)

# Linux下工具的安装
---
基于Apt的软件
1. 聊天工具， 微信; qq
1. ssh工具，Remmina; deepin-terminal
1. 浏览器， Chromium; Firefox; chrome
1. 科学工具，shadowsocks; chrome插件[setupvpn]
1. 文本编辑器， atom; vsCode; Unity
1. wps， 自带的; wps
1. vpn，openvpn; esayconnect
1. pdf查看器， okular
1. 远程工具，teamviewer
1. py工具， pycharm; pip2; pip3; py2; py3
1. 版本控制客户端， git;gitkraken;svn;RapidSVN
1. 数据库客户端， dbeaver
1. 打包工具， tar;zip
1. 下载工具, wget
1. 局域网端口侦测工具, zenmap
1. 其他的东西, 下拉式终端tilda;下拉GNOME终端guake; HTTP 协议文件共享服务Chfs; MAC主题包Cairo-dock; 截图工具~~Shutter~~, flameshot
1. ftp工具，FileZilla
1. 连接windows，rdesktop
1. 文件对比工具， meld(GUI); diff(command)
1.  笔记， nixnote2（印象笔记客户端）
1. 光盘刻录，Brasero
1. 护眼，fluxgui
1. 输入法，sougoupinyin

---
基于snap的软件(安装服务后需要重启才能使用)
安装snap: sudo apt-get install snapd snapcraft
安装snap商店: sudo snap install snap-store
1. redis客户端: RedisDesktopManager
1. git客户端: GitKraken


---
---

+ 安装记录：
  + 更新: apt-get update
  + 解决依赖: sudo apt-get --fix-broken -y install

1. 聊天工具
    1. QQ，微信: 需要安装[deepin-wine环境](https://github.com/wszqkzqk/deepin-wine-ubuntu);
    然后去[Deepin-wine 容器的存档](https://gitee.com/wszqkzqk/deepin-wine-containers-for-ubuntu/);
    下载对应的包

1. ssh工具
    1. Remmina:
    ```
    sudo apt-add-repository ppa:remmina-ppa-team/remmina-next
    sudo apt update
    sudo apt install -y remmina remmina-plugin-rdp remmina-plugin-secret remmina-plugin-spice
    ```

    1. 深度终端: 
    
    ```
    # deepin-terminal 2.9.2
    sudo apt-get --fix-broken install
    sudo apt install -y deepin-menu expect lrzsz
    wget http://kr.archive.ubuntu.com/ubuntu/pool/universe/d/deepin-terminal/deepin-terminal_2.9.2-1_amd64.deb
    sudo dpkg -i deepin-terminal_2.9.2-1_amd64.deb

    # deepin-terminal 3.0以上版本依赖libc6 (>= 2.29)
    ```

1. 浏览器
    1. Chromium: `sudo apt-get install chromium-browser`
        + 问题1: 长时间不关闭，会导致物理和虚拟内存的占用非常高，需要重启浏览器
    1. Firefox: Mint系统自带
    1. chrome: 
    ```
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo dpkg -i google-chrome-stable_current_amd64.deb
    ```

1. 科学工具
    1. shadowsocks: `pip install shadowsocks privoxy`
    1. chrome插件:
        + setupvpn:
        ```
        wget https://baseserver.io/sv/client/download/Chrome-SetupVPN-3.7.0.crx
        拖拽到浏览器chrome安装
        ```

1. 文本编辑器
    1. atom:
    ```
    wget https://github.com/atom/atom/releases/download/v1.38.1/atom-amd64.deb
    sudo dpkg -i atom-amd64.deb
    ```
    1. vsCode:
    ```
    wget https://vscode.cdn.azure.cn/stable/c7d83e57cd18f18026a8162d042843bda1bcf21f/code_1.35.1-1560350270_amd64.deb
    sudo dpkg -i code_1.35.1-1560350270_amd64.deb
    ```
    1. Unity:
    ```
    wget https://public-cdn.cloud.unity3d.com/hub/prod/UnityHubSetup.AppImage
    chmod +x UnityHubSetup.AppImage
    ./UnityHubSetup.AppImage
    # 启动 Unity Hub 后，它会要求你使用 Unity ID 登录（或注册）以激活许可证。
    # 使用 Unity ID 登录后，进入 “Installs” 选项（如上图所示）并添加所需的版本/组件。
    ```

1. wps
    1. LibreOffice: Mint系统自带
    1. wps:
    ```
    wget https://wdl1.cache.wps.cn/wps/download/ep/Linux2019/8392/wps-office_11.1.0.8392_amd64.deb
    sudo dpkg -i wps-office_11.1.0.8392_amd64.deb
    ```

1. vpn
    1. openvpn: [官网下载客户端](https://www.techspot.com/downloads/5182-openvpn.html)
    ```
    wget https://files02.tchspt.com/storage2/temp/openvpn-2.4.7.tar.gz
    sudo apt install -y openssl libssl-dev net-tools liblzo2-dev libpam0g-dev
    tar -zxf openvpn-2.4.7.tar.gz
    cd openvpn-2.4.7
    ./configure
    make
    sudo make install
    ```
    1. esayconnect: 待测试

1. pdf查看器
    1. okular: `sudo apt-get -y install okular`

1. 远程工具
    1. teamviewer:
    ```
    wget https://download.teamviewer.com/download/linux/teamviewer_amd64.deb
    sudo dpkg -i teamviewer_amd64.deb
    ```

1. py工具,py环境
    1. pycharm：
    ```
    wget https://download.jetbrains.8686c.com/python/pycharm-community-2019.1.3.tar.gz
    sudo tar -zxf pycharm-community-2019.1.3.tar.gz -C /usr/local/share
    ls -n /usr/local/share/pycharm-community-2019.1.3/bin/pycharm.sh ~/桌面
    # 运行时选择运行
    ```
    1. py2: Mint系统自带, python -V
    1. pip2: Mint系统自带, pip2 -V
    1. py3: Mint系统自带, python3 -V
    1. pip3: `sudo apt-get install -y python3-pip`， pip3 -V

1. 版本控制客户端
    1. git: `sudo apt install -y git`
    1. gitkraken:
    ```
    wget https://release.axocdn.com/linux/gitkraken-amd64.deb
    sudo dpkg -i gitkraken-amd64.deb
    ```
    1. svn: `sudo apt install -y subversion`
    1. RapidSVN: `sudo apt-get install -y rapidsvn`

1. 数据库客户端
    1. dbeaver:
    ```
    wget https://github.com/dbeaver/dbeaver/releases/download/6.1.0/dbeaver-ce_6.1.0_amd64.deb
    sudo dpkg -i dbeaver-ce_6.1.0_amd64.deb
    ```

1. 打包工具
    1. tar: Mint系统自带
    1. zip: Mint系统自带

1. 下载工具
    1. wget: Mint系统自带

1. 局域网端口侦测工具
    1. zenmap: `sudo apt install -y zenmap`

1. 其他的东西
    1. 下拉式终端 tilda: `sudo apt-get install -y tilda`
    1. 下拉式GNOME终端: `sudo apt install guake`
    1. HTTP 协议文件共享服务 Chfs:
    ```
    wget https://files-cdn.cnblogs.com/files/dcb3688/chfs-linux-amd64-1.4.zip
    unzip chfs-linux-amd64-1.4.zip
    chmod +x chfs
    ./chfs --port 8080 --path /home/lshi/下载
    ```
    1. MAC主题包 Cairo-dock:
    ```
    系统管理-软件管理器-搜索'Cairo-dock'
    安装,设置开机自启动
    ```
    1. 截图工具
        + ~~Shutter: `sudo apt-get install -y shutter`~~ --不好用
        + flameshot:
    ```
    sudo apt install -y flameshot
    设置系统快捷键，可取消显示托盘图标
    ```

1. ftp工具
    1. FileZilla: `sudo apt-get install -y filezilla`

1. 连接windows
    1. rdesktop: `sudo apt install -y rdesktop`

1. 文件对比工具
    1. meld:
    `sudo apt install -y meld`
    1. diff: 系统自带

1. 笔记
    1. nixnote2:
    ```
    sudo add-apt-repository ppa:nixnote/nixnote2-daily
    sudo apt update
    sudo apt install nixnote2
    # 然后在'file文件'中建立账户,然后使用建立的账户，
    # 选择“印象笔记”（这个是国服），使用'工具'中的同步，这时会进入印象笔记大陆的服务器，
    # 如果选择的是印象笔记国际版，进入的就是国际版。
    # 两个域名是不一样的，在没登录前可以在~/.nixnote/accounts.conf中看到。
    # 登录页面左上角也不一样，国际版是Eventnote，国服是印象笔记。
    # 在登录国服时候，输入完邮箱地址一直不会显示密码框，
    # 这个时候点击左上角的“印象笔记”链接，然后会打开网页版的印象笔记页面，在里面找到登录页面，正常登录。
    # 然后关闭登录框，再从'工具'中的同步进入，这个时候就会看到授权提示了。
    ```
1. 光盘刻录
    1. Brasero: `sudo apt install -y brasero`

1. 护眼
    1. fluxgui:
    ```
    sudo add-apt-repository ppa:nathan-renniewaldock/flux
    sudo apt-get update
    sudo apt-get install -y fluxgui
    ```
1. 输入法
    1. sougoupinyin:
    ```
    # 依赖于Fcitx框架
    wget http://cdn2.ime.sogou.com/dl/index/1524572264/sogoupinyin_2.2.0.0108_amd64.deb
    sudo dpkg -i sogoupinyin_2.2.0.0108_amd64.deb
    # 可能会有一些包没有安装，通过--fix-broken来解决冲突，并安装上sougoupinyin
    sudo apt-get --fix-broken -y install
    # 重启，我是重启了
    ```


## 基于snap的软件

1. redis客户端
    1. RedisDesktopManager: `sudo snap install redis-desktop-manager`
1. git客户端
    1. GitKraken: `sudo snap install gitkraken`


---
Linux System Software 参考:
[Linux发行版软件](https://www.lulinux.com/archives/2787)

[为Linux Mint设置为雅黑字体](https://blog.csdn.net/wangrui1573/article/details/81973919)

[安装Linux Mint 18.2后要做的20件事](https://www.cnblogs.com/xcb0730/p/9286708.html)

[使用 Linux Mint 作为主要操作系统的一些个人常用软件](https://www.cnblogs.com/xiaoshen666/p/10916857.html)

[linux常用的几个软件](https://www.cnblogs.com/dcb3688/p/4607976.html)

[让Linux Mint看起来像Mac](https://imcn.me/html/y2018/33686.html)


```
# 1.配置字体
wget http://ftp-idc.pconline.com.cn/6bdd4de6de0e47545d1f0631a868eb73/pub/download/201010/yaheiFont_CHS.zip
unzip yaheiFont_CHS.zip
sudo mkdir /usr/share/fonts/msyh
sudo cp msyh.ttf msyhbd.ttf /usr/share/fonts/msyh
sudo fc-cache -fv
sudo rm -f /usr/share/fonts/truetype/arphic/{ukai.ttc,uming.ttc}
# 2. 更新apt源
sudo apt update
sudo apt upgrade -y
# 3. 安装软件
sudo apt install -y vim git
# deepin-wine-ubuntu
git clone https://gitee.com/wszqkzqk/deepin-wine-for-ubuntu.git
cd deepin-wine-for-ubuntu
yes | ./install.sh

# install wine-tim
wget https://mirrors.aliyun.com/deepin/pool/non-free/d/deepin.com.qq.office/deepin.com.qq.office_2.0.0deepin4_i386.deb
sudo dpkg -i deepin.com.qq.office_2.0.0deepin4_i386.deb

# install wine-wechat
wget https://mirrors.aliyun.com/deepin/pool/non-free/d/deepin.com.wechat/deepin.com.wechat_2.6.2.31deepin0_i386.deb
sudo dpkg -i deepin.com.wechat_2.6.2.31deepin0_i386.deb

# install deepin-terminal
sudo apt-get --fix-broken install
sudo apt install -y deepin-menu expect lrzsz
wget http://kr.archive.ubuntu.com/ubuntu/pool/universe/d/deepin-terminal/deepin-terminal_2.9.2-1_amd64.deb
sudo dpkg -i deepin-terminal_2.9.2-1_amd64.deb

# install chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb

# install vscode
wget https://vscode.cdn.azure.cn/stable/c7d83e57cd18f18026a8162d042843bda1bcf21f/code_1.35.1-1560350270_amd64.deb
sudo dpkg -i code_1.35.1-1560350270_amd64.deb

# install wps
wget https://wdl1.cache.wps.cn/wps/download/ep/Linux2019/8392/wps-office_11.1.0.8392_amd64.deb
sudo dpkg -i wps-office_11.1.0.8392_amd64.deb

# install vpn
wget https://files02.tchspt.com/storage2/temp/openvpn-2.4.7.tar.gz
sudo apt install -y openssl libssl-dev net-tools liblzo2-dev libpam0g-dev
tar -zxf openvpn-2.4.7.tar.gz
cd openvpn-2.4.7
./configure
make
sudo make install
cd -

# install pdf
sudo apt-get -y install okular

# install teamviewer
wget https://download.teamviewer.com/download/linux/teamviewer_amd64.deb
sudo dpkg -i teamviewer_amd64.deb

# install gitkraken
wget https://release.axocdn.com/linux/gitkraken-amd64.deb
sudo dpkg -i gitkraken-amd64.deb

# install svn rapidsvn
sudo apt install -y subversion rapidsvn

# install dbeaver
wget https://github.com/dbeaver/dbeaver/releases/download/6.1.0/dbeaver-ce_6.1.0_amd64.deb
sudo dpkg -i dbeaver-ce_6.1.0_amd64.deb

# install flameshot
sudo apt install -y flameshot

# install FileZilla
sudo apt-get install -y filezilla

# install rdesktop
sudo apt install -y rdesktop

# install meld 
sudo apt install -y meld

# install brasero
sudo apt install -y brasero

# install sougoupinyin
wget http://cdn2.ime.sogou.com/dl/index/1524572264/sogoupinyin_2.2.0.0108_amd64.deb
sudo dpkg -i sogoupinyin_2.2.0.0108_amd64.deb
sudo apt-get --fix-broken -y install
```
