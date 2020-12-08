## docker.gitlab
离线一键部署gitlab的自动化脚本，可以定制ssh和http的端口号，包括映射gitlab里面的所有数据
#### 1.dockerinstall:  
install.sh和load.sh脚本的执行需要如下两个离线包放入同级目录,主要功能是离线方式安装docker和gitlab的镜像
```
docker-static-18.09.9.tar.gz
gitlab.12.9.10.tar
```  

#### 2.gitlab:
start.sh是创建和维护gitlab服务的脚本,gitlab的数据被映射到本地磁盘
docker被删除,重新在被映射的目录上创建docker，所有数据不会丢失

#### 3.自定义服务端口修改:
a.http的端口号默认是8090,改成其它需要修改配置文件如下
    1.修改./gitlab/start.sh +8中 HTTP_PORT=8090
    2.修改./gitlab/configs/gitlab.rb +29 external_url 'http://192.168.1.192:8090'  这个url也是对外访问的url地址，可以是域名也可以是ip地址
b.ssh的端口号默认是220,改成其它需要修改配置文件如下
    1.修改./gitlab/start.sh +10中 SSH_PORT=220 这个是docker中ssh的端口号
    2.修改./gitlab/configs/sshd_config +5 Port 220  这个是git clone通过ssh方式的端口号

#### 4.备份
进入实例容器，执行gitlab-rake gitlab:backup:create，备份文件在/var/opt/gitlab/backups，对应挂载在宿主机的目录，下存在类似于1569482945_2019_09_26_11.1.4_gitlab_backup.tar的文件，表示备份成功
在备份的过程中出现一个小插曲，备份出现报错，提示硬盘空间不足，需要预留出来将近3个G的空间
修改默认的备份目录（/etc/gitlab/gitlab.rb）
gitlab_rails['backup_path'] = "/var/opt/gitlab/backups"
修改完成后执行gitlab-ctl reconfigure

#### 5.迁移[只能gitlab相同版本之间迁移]
传送备份文件到指定文件夹下
```
scp  1569482945_2019_09_26_11.1.4_gitlab_backup.tar root@192.168.1.192:/home/app/gitlab/data/backup
```
使用上述命令启动宿主服务器
进去宿主服务器容器执行命令修改备份文件权限
```
chmod 777 1569482945_2019_09_26_11.1.4_gitlab_backup.tar
```
停止相关数据连接服务
```
gitlab-ctl stop unicorn
gitlab-ctl stop sidekiq
```
恢复备份文件（需要输入两次yes）
```
gitlab-rake gitlab:backup:restore BACKUP=1569482945_2019_09_26_11.1.4
```
重新启动gitlab
```
service gitlab-ctl start
```

#### 6.UOS下安装docker时 使用[docker ps -a]报错提示无权限:添加当前用户uos到docker组里后重启电脑,或者直接使用root
```
sudo usermod -a -G docker uos
```



