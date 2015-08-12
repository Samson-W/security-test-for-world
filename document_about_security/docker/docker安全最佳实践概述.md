1、GRSEC and PaX  
加固主机系统。  

2、Use Docker in combination with AppArmor/SELinux/TOMOYO  
使用强制访问控制（mandatory access control (MAC)）对Docker中使用的各种资源根据业务场景的具体分析进行资源的访问的控制。  

3、Limit traffic with iptables  
使用netfilter对网络的出入访问根据实际应用会被外网访问的端口、应用会与外网的交互网络地址、端口、协议等进行梳理，进行白名单的生成并使用uptables进行配置以限制访问；  

4、Do not run software as root：不要使用root用户运行应用程序  
在实际应用程序使用中，有一些必须要使用root用户才能够进行的操作，那么从安全的角度，需要将这一部分与仅使用普通用户权限执行的部分分离解耦。那么如何在docker中使用普通用户权限对不需要root权限执行的部分进行实施呢？  

在编写dockerfile时，使用类似如下的命令进行创建一个普通权限的用户，并设置创建的UID为以后运行程序的用户，如下：  
RUN useradd noroot -u 1000 -s /bin/bash --no-create-home  
USER noroot  
RUN Application_name  

docker命令参考：  
https://docs.docker.com/reference/builder/#user  
https://docs.docker.com/reference/builder/#run  

5、docker run时不要使用--privileged选项  
默认情况下，Docker容器是没有特权的，默认一个容器是不允许访问任何设备的；当使用--privileged选项时，则此窗口将能访问所有设备。例如：打开此选项后，即可以进行对Host中的/dev/下有的所有设备进行操作。若非要对host上的某些设备进行访问的话，可以使用--device来进行设备的添加，而不是全部的设备。  

Ref:  
https://docs.docker.com/reference/run/#security-configuration  

6、Use –cap-drop and –cap-add  
使用这两个选项可能对更加细粒度的控制设置，可以添加或删除GNU Linux的能力在此容器中，可以使用的参数名支持http://linux.die.net/man/7/capabilities此网页中的所有能力选项参数。  

Ref:  
https://docs.docker.com/reference/run/#security-configuration  
http://linux.die.net/man/7/capabilities  

7、关注docker的漏洞信息、及时更新修复漏洞的安全补丁。  

REF：  
http://linux-audit.com/docker-security-best-practices-for-your-vessel-and-containers/  