## 结论：
    对于将host下的普通用户添加到docker组中后不使用sudo即可执行docker程序，会给大
    家造成一种启动docker是以非root权限进行启动的假象，其实这样只是减少了每次使用
    sudo时输入密码的过程罢了，其实docker本身还是以sudo的权限在运行的。
    
## 以下是实际的验证过程:

还是以shadowsocks的Dockerfile来进行验证。
rootyygy是build所得。

    docker build -rm -t rootyygy .

## 1、将host中的普通用户添加到doker组后应用程序的运行状态：

### 查看当前用户及所属组：

    ufo@ufo:~/$ id
    uid=1000(ufo) gid=1000(ufo) 组=1000(ufo),24(cdrom),25(floppy),29(audio),30(dip),44(video),46(plugdev),104(scanner),109(bluetooth),111(netdev),999(docker)

### 启动rootyygy

    ufo@ufo:~/$ docker start rootyygy
    rootyygy
    ufo@ufo:~/$ docker ps
    CONTAINER ID        IMAGE               COMMAND                CREATED             STATUS              PORTS               NAMES
    4d3813cacaab        rootyygy            "/bin/tini -- /usr/l   53 minutes ago      Up 5 seconds        443/tcp, 8388/tcp   rootyygy            

### 在host中查看docker进程的状态，是以root进行启动的：

    ufo@ufo:~/$ ps aux | grep docker
    root       3449  0.0  0.4 923432 19328 ?        Sl   12:20   0:18 /usr/bin/docker -d -p /var/run/docker.pid --insecure-registry hub.lianshinet.com:5000
    ufo       11626  0.0  0.0  10156  2016 pts/3    R+   17:32   0:00 grep docker


### 在host中查看应用程序的状态，是以root进行启动的：

    ufo@ufo:~/$ ps aux | grep shad
    root      11253  0.0  0.0   1104     4 ?        Ss   17:06   0:00 /bin/tini -- /usr/local/bin/shadowsocks.sh
    root      11258  0.0  0.0  20032  2808 ?        S    17:06   0:00 /bin/bash /usr/local/bin/shadowsocks.sh
    root      11259  0.4  0.3  45764 14288 ?        S    17:06   0:00 /usr/bin/python /usr/local/bin/ssserver -c /etc/shadowsocks.json
    ufo       11278  0.0  0.0  10152  1960 pts/3    S+   17:07   0:00 grep shad

### 进行容器中进行进程的查看，是以root进行启动的：

    ufo@ufo:~/$ docker inspect -f {{.State.Pid}} rootyygy
    11253
    
    ufo@ufo:~/$ sudo nsenter --target 11253 --mount --uts --ipc --net --pid
    [sudo] password for ufo: 
    root@4d3813cacaab:/# ps aux
    USER        PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
    root          1  0.0  0.0   1104     4 ?        Ss   09:06   0:00 /bin/tini -- /usr/local/bin/shadowsocks.sh
    root          6  0.0  0.0  20032  2808 ?        S    09:06   0:00 /bin/bash /usr/local/bin/shadowsocks.sh
    root          7  0.0  0.3  45764 14288 ?        S    09:06   0:00 /usr/bin/python /usr/local/bin/ssserver -c /etc/shadowsocks.json
    root         19  0.0  0.0  20256  3240 ?        S    09:13   0:00 -bash
    root         23  0.0  0.0  17488  2056 ?        R+   09:13   0:00 ps aux

## 2、host中的用户没有添加到docker组的用户使用sudo启动容器后的运行状态：

### 查看当前用户及所属组：

    dj@ufo:~/$ id
    uid=1002(dj) gid=1002(dj) 组=1002(dj)

### 启动rootyygy

    dj@ufo:~/$ sudo docker start rootyygy
    rootyygy

    dj@ufo:~/$ docker ps
    Get http:///var/run/docker.sock/v1.19/containers/json: dial unix /var/run/docker.sock: permission denied. Are you trying to connect to a TLS-enabled daemon without TLS?
    dj@ufo:~/$ sudo docker ps
    CONTAINER ID        IMAGE               COMMAND                CREATED             STATUS              PORTS               NAMES
    4d3813cacaab        rootyygy            "/bin/tini -- /usr/l   About an hour ago   Up 53 seconds       443/tcp, 8388/tcp   rootyygy

### 在host中查看docker进程的状态，是以root进行启动的：

    dj@ufo:$ ps aux | grep docker
    root       3449  0.0  0.4 923432 18784 ?        Sl   12:20   0:18 /usr/bin/docker -d -p /var/run/docker.pid --insecure-registry hub.lianshinet.com:5000
    dj        11532  0.0  0.0  10156  2112 pts/1    S+   17:29   0:00 grep docker

### 在host中查看应用程序的状态，是以root进行启动的：

    dj@ufo:$ ps aux | grep nginx
    dj        11172  0.0  0.0  10152  1944 pts/1    S+   17:02   0:00 grep nginx
    dj@ufo:~/$ ps aux | grep shad
    root      11152  0.1  0.0   1104     4 ?        Ss   17:02   0:00 /bin/tini -- /usr/local/bin/shadowsocks.sh    
    root      11158  0.0  0.0  20032  2740 ?        S    17:02   0:00 /bin/bash /usr/local/bin/shadowsocks.sh
    root      11159  0.8  0.3  45764 14400 ?        S    17:02   0:00 /usr/bin/python /usr/local/bin/ssserver -c /etc/shadowsocks.json
    dj        11174  0.0  0.0  10152  1956 pts/1    S+   17:02   0:00 grep shad

### 进行容器中进行进程的查看，是以root进行启动的：

    dj@ufo:~/$ sudo docker inspect -f {{.State.Pid}} rootyygy
    11419

    dj@ufo:~/$ sudo nsenter --target 11419 --mount --uts --ipc --net --pid
    root@4d3813cacaab:/# ps aux
    USER        PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
    root          1  0.0  0.0   1104     4 ?        Ss   09:17   0:00 /bin/tini -- /usr/local/bin/shadowsocks.sh
    root          6  0.0  0.0  20032  2788 ?        S    09:17   0:00 /bin/bash /usr/local/bin/shadowsocks.sh
    root          7  0.0  0.3  45764 14392 ?        S    09:17   0:00 /usr/bin/python /usr/local/bin/ssserver -c /etc/shadowsocks.json
    root         19  0.0  0.0  20256  3244 ?        S    09:19   0:00 -bash
    root         23  0.0  0.0  17488  2048 ?        R+   09:19   0:00 ps aux