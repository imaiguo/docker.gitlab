#!/bin/bash

APP_NAME=docker-static
APP_VERSION=18.09.9

#帮助说明
print_help()
{
  cat<< HELP
	parameter description:
	eg:sh start.sh 0
	----------------------------------------------
	-- 0	- help
	-- 1	- install docker(su root)
	$APP_NAME current version:$APP_VERSION
HELP
}

# 检查磁盘
check_disk()
{
	echo "Start checking disk"
	max_disk=`df | grep -v Filesystem | sort -k2nr | head -1 | awk '{print $6}'`
	echo "The maximum detected data disk is mounted on the path:$max_disk,the container mount path is $max_disk,confirm to continue?(y/n)"
	read result
	if [[ $result != y ]]; then echo -e "exit!" && exit 1;fi
}


#初始化docker
install_docker()
{
	if [[ -f 'which docker' ]]
	then
		echo "Docker installed"
		if [[ `systemctl status docker` =~ 'active (running)' ]]
		then
			echo "Docker started"
		else
			systemctl daemon-reload
			systemctl restart docker
			systemctl enable docker
		fi
	else
		echo "Start installing docker-static-18.09.9.tar.gz"
		tar -zxvf ./docker-static-18.09.9.tar.gz
		chmod +x docker/*
		cp docker/* /usr/local/bin
		mkdir -p $max_disk/docker
		cat > /lib/systemd/system/docker.service <<"EOF"
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com

[Service]
Type=notify
ExecStart=/usr/local/bin/dockerd-ce  --graph=/var/lib/docker --log-level=error
ExecReload=/bin/kill -s HUP $MAINPID
TimeoutSec=0
RestartSec=2
Restart=always
StartLimitBurst=3
StartLimitInterval=60s
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
TasksMax=infinity
Delegate=yes
KillMode=process

[Install]
WantedBy=multi-user.target
EOF
		sed -i s#/var/lib/docker#$max_disk/docker#g /lib/systemd/system/docker.service
		systemctl daemon-reload
		systemctl restart docker
		systemctl enable docker
	fi
	 
#兼容手工删除
cp /usr/local/bin/docker /usr/bin
}


#用户授权
docker_author_user()
{
	username=$USER
	echo "Start adding user:$username authority...."
	if [[ `cat /etc/group` =~ docker ]]; then echo Docker group already exists!; else groupadd docker;fi
	usermod -a -G docker $username
	usermod -a -G root $username
	newgrp docker 
	echo "$username		ALL=(ALL)	ALL" >> /etc/sudoers
}

#初始化环境
install_docker_main()
{
	check_disk
	install_docker
	docker_author_user
}


#用户授权
author_user()
{
	username=$USER
	chown -R $username ./
	chmod -R 755 ./
}


#初始化环境
install()
{
	if [[ -f `which docker` ]]; then
		echo -e "System have Docker.\nDocker initializing completed!"
		if [[ `id -u ` -eq 0 ]] && [[ $USER != "root" ]];then
			echo -e "Please use user:[$USER]"
			echo -e "1.exit"
		fi
		printBlankRow
	fi
	
	
	if [ `id -u` -ne 0 ];then
		echo "!!! Please switch to the root to initializing docker!!!"
		echo "1.su root"
		echo "2.sh start.sh 1"
		echo "3.ext (Use user:[$USER])"
		printBlankRow
	else
		install_docker_main
		author_user
		echo -e "Docker initialization completed!"
		if [[ `id -u` -eq 0 ]] && [[ $USER != "root" ]]; then
			echo -e "Please use user:[$USER]"
			echo -e "1.exit"
		fi
		printBlankRow
	fi
}


#检查初始化环境
check_install()
{
	if [[ ! -f `which docker` ]]; then
		echo -e "Please initialize the docker environment! [ sh start.sh 1]"
		echo -e ""
		printBlankRow
	fi
	
	if [[ `id -u`  -eq 0 ]]  && [[ $USER != "root" ]];then
		echo -e "Please use user:[$USER]"
		echo -e "1.exit"
		printBlankRow
	fi
}


printBlankRow()
{
	echo -e "\n\n"
	exit 1
}

#shell start
case $1 in
	0)
		print_help && printBlankRow
		;;
	1)
		install && printBlankRow
		;;
	*)
		print_help && printBlankRow
		;;
esac




