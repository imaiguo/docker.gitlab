#!/bin/bash
Project=gitlab
Version=12.9.10

repository=gitlab
tag=12.9.10

HTTP_PORT=8090
HTTPS_PORT=4430
SSH_PORT=220

#关闭镜像
docker_stop()
{
	echo "image $DCOKER_NAME $1 stop"
	DOCKER_PS=`docker ps | grep $1 | awk '{print $1}'`
	DOCKER_PS_A=`docker ps -a | grep $1 | awk '{print $1}'`
	if [ -n "$DOCKER_PS" ] ; then
		docker stop $DOCKER_PS
		echo "[$DOCKER_PS] docker stop success!"
	fi
	if [ -n "$DOCKER_PS_A" ]; then
		docker rm $DOCKER_PS_A
		echo "[$DOCKER_PS_A] docker rm success!"
	fi
	echo -e "docker $1 stop success!"
}


print_help()
{
  cat<< HELP
	parameter description:
	eg:sh start.sh 0
	----------------------------------------------
	-- 0    - help
	-- 1    - create & start gitlab container
	-- 2    - stop gitlab container
	-- 3    - start gitlab container
	-- 4    - run reconfigure script
	-- 5    - view running images
	-- 6    - view all images
	-- 7    - start service

	$Project current version:$Version
HELP
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

	

#关闭镜像
docker_stop()
{
	check_install
	echo "image $Project $1 stop"
	DOCKER_PS=`docker ps | grep $1 | awk '{print $1}'`
	DOCKER_PS_A=`docker ps -a | grep $1 | awk '{print $1}'`
	if [ -n "$DOCKER_PS" ] ; then
		docker stop $DOCKER_PS
		echo "[$DOCKER_PS] docker stop success!"
	fi
	if [ -n "$DOCKER_PS_A" ]; then
		docker rm $DOCKER_PS_A
		echo "[$DOCKER_PS_A] docker rm success!"
	fi
	echo -e "docker $1 stop success!"
}

run_proc()
{
	echo "now start program....."
    docker exec -itd ${Project}_${Version} bash /etc/gitlab/run.sh

}

run_reconfigure()
{
	echo "now reconfigure program....."
    docker exec -it ${Project}_${Version} bash /etc/gitlab/reconfigure.sh
}



findtimezone()
{
	if [ ! -f "/etc/timezone" ]; then
		echo "Not find timezone."
		echo " please set timezone to [/etc/timezone]."
		exit -1
	else
		echo "find timezone."
	fi


	tzone=`cat /etc/timezone`
	if [ "${tzone}" != "" ];  then
		echo "Find timezone[${tzone}]"
	else
		echo "Timezone is NULL."
		echo " please set timezone to [/etc/timezone]."
		exit -1
	fi
}


create_start()
{
	findtimezone
	check_install
	params=""
	docker_stop ${Project}_${Version}

	if [ "${HTTP_PORT}" != "" ]; then
		params="${params} -p ${HTTP_PORT}:${HTTP_PORT}"
	fi

	if [ "${HTTPS_PORT}" != "" ]; then
		params="${params} -p ${HTTPS_PORT}:4430"
	fi

	if [ "${SSH_PORT}" != "" ]; then
		params="${params} -p ${SSH_PORT}:${SSH_PORT}"
	fi


	params="${params} --name ${Project}_${Version}"
	params="${params} --ulimit core=0"
	params="${params} --restart=always"
	params="${params} -v /etc/localtime:/etc/localtime:ro"
	params="${params} -v /etc/timezone:/etc/timezone:ro"
	
    params="${params} -v $(pwd)/configs:/etc/gitlab"
    params="${params} -v $(pwd)/log:/var/log/gitlab"
    params="${params} -v $(pwd)/data:/var/opt/gitlab"
	params="${params} -v $(pwd)/configs/sshd_config:/etc/ssh/sshd_config:ro"

	echo "Starting ${Project} ${Version} container..."

	docker run -itd ${params} ${repository}:${tag} /bin/bash > /dev/null

	if [ $? -ne 0 ]; then
		echo "Run failed. Container maybe is running."
		exit 1
	fi

	container_id=`docker ps --filter ancestor=${repository}:$tag --format "{{.ID}}"`
	if [ "${container_id}" == "" ]; then
		echo "Error: Start container failed!"
		echo "Exit."
		exit 1
	fi

	echo "container_id:[${container_id}]"
	echo .
	
	#run_proc
	echo "Start ${Project} ${Version} successd."
}

#shell start
case $1 in
	0)
		print_help && printBlankRow
		;;
	1)
		create_start && printBlankRow
		;;
	2)
		docker stop ${Project}_${Version} && printBlankRow
		;;
	3)
		docker start ${Project}_${Version} && printBlankRow
		;;
	4)
		 run_reconfigure && printBlankRow
		;;
	5)
		docker ps && printBlankRow
		;;
	6)
		docker ps -a && printBlankRow
		;;
    7)
        run_proc
        ;;

	*)
		print_help && printBlankRow
		;;
esac


		
		
		
