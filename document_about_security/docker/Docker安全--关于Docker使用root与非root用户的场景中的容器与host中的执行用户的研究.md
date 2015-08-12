## 结论

    实际进行测试的Dockerfile是shadowsocks的Dockerfile，在此Dockerfile中添加两行即
    可使后续运行应用程序时的权限为非root用户，将进行对比docker中的进程状态与Host
    环境中的应用程序的运行状态进行对比，可以看出在docker中以普通用户权限运行的程
    序在host主机中运行的也是普通用户权限，在docker中以root用户权限运行的程序在host
    主机中运行的也是root用户权限。

## 前提说明
    为了区分root与非root用户的区别，若在Dockerfile中不使用USER进行指定用户的情况
    下，将会默认按root的权限进行启动应用程序，为了安全考虑，除非必须使用root权限，
    绝不使用root权限，那么就在Dockerfile中要执行程序前使用USER指定非root用户来执行
    应用程序，只需要在执行程序前添加一个非root权限用户并使用USER命令切换到此非root用户即可。

### 具体修改方法

添加如下两行在ENTRYPOINT ["/bin/tini", "--", "/usr/local/bin/shadowsocks.sh"]的前面：

RUN useradd noroot -u 1000 -s /bin/bash 
USER noroot

### 编译镜像方法
然后在Dockerfile目录下分别在修改前后执行：
修改前：

    docker build -rm -t rootyygy .
    
修改后：

    docker build -rm -t norootyygy .

其中rootyygy为默认root用户执行应用程序的镜像，norootyygy为普通用户执行应用程序的镜像。

### 启动镜像：

    docker run -d --name rootyygy rootyygy
    docker run -d --name norootyygy norootyygy

### 得到两个容器的进程号：

    $ docker inspect -f {{.State.Pid}} rootyygy
    9818
    $ docker inspect -f {{.State.Pid}} norootyygy
    9875

进入两个容器中：
### noroot容器中：

    sudo nsenter --target 9875 --mount --uts --ipc --net --pid

#### 在容器中显示进程：

    root@b5ddee5e9e3b:/# ps aux
    USER        PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
    noroot        1  0.0  0.0   1104     4 ?        Ss   08:14   0:00 /bin/tini -- /usr/local/bin/shadowsocks.sh
    noroot        7  0.0  0.0  20032  2816 ?        S    08:14   0:00 /bin/bash /usr/local/bin/shadowsocks.sh
    noroot        8  0.0  0.3  45764 14368 ?        S    08:14   0:00 /usr/bin/python /usr/local/bin/ssserver -c /etc/shadowsocks.json
    root         20  0.0  0.0  20256  3192 ?        S    08:17   0:00 -bash
    root         25  0.0  0.0  17488  2040 ?        R+   08:21   0:00 ps aux

#### 在host主机的进程查看：

    $ ps aux | grep shadowsocks
    ufo       10594  0.0  0.0   1104     4 ?        Ss   16:51   0:00 /bin/tini -- /usr/local/bin/shadowsocks.sh
    ufo       10599  0.0  0.0  20032  2808 ?        S    16:51   0:00 /bin/bash /usr/local/bin/shadowsocks.sh
    ufo       10600  0.0  0.3  45764 14292 ?        S    16:51   0:00 /usr/bin/python /usr/local/bin/ssserver -c /etc/shadowsocks.json
    ufo       10874  0.0  0.0  10152  1960 pts/1    S+   16:52   0:00 grep shadowsocks

### root容器中：

    sudo nsenter --target 9818 --mount --uts --ipc --net --pid

#### 在容器中显示进程：

    root@4d3813cacaab:/# ps aux
    USER        PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
    root          1  0.0  0.0   1104     4 ?        Ss   08:13   0:00 /bin/tini -- /usr/local/bin/shadowsocks.sh
    root          6  0.0  0.0  20032  2748 ?        S    08:13   0:00 /bin/bash /usr/local/bin/shadowsocks.sh
    root          7  0.0  0.3  45764 14392 ?        S    08:13   0:00 /usr/bin/python /usr/local/bin/ssserver -c /etc/shadowsocks.json
    root         19  0.0  0.0  20256  3232 ?        S    08:16   0:00 -bash
    root         24  0.0  0.0  17488  2044 ?        R+   08:24   0:00 ps aux

#### 在host主机的进程查看：

    $ ps aux | grep shadowsocks
    root       9818  0.0  0.0   1104     4 ?        Ss   16:13   0:00 /bin/tini -- /usr/local/bin/shadowsocks.sh
    root       9823  0.0  0.0  20032  2748 ?        S    16:13   0:00 /bin/bash /usr/local/bin/shadowsocks.sh
    root       9824  0.0  0.3  45764 14392 ?        S    16:13   0:00 /usr/bin/python /usr/local/bin/ssserver -c /etc/shadowsocks.json
    ufo       10298  0.0  0.0  10152  1964 pts/1    R+   16:48   0:00 grep shadowsocks