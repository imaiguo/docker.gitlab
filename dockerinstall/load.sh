#!/bin/bash

APPP_NAME=gitlab
APPP_VERSION=12.9.10


#帮助说明
print_help()
{
  cat<< HELP
	parameter description:
	eg:sh start.sh 0
	----------------------------------------------
	-- 0	- help
	-- 1	- load gitlab image
	$APPP_NAME current version:[$APPP_VERSION]
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

#装载镜像
image_load(){
	check_install
	IMAGE_ALREADY=`docker images | grep $1 |grep $2`
	if [ -n "$IMAGE_ALREADY" ];	then
		echo $IMAGE_ALREADY
		echo "$1 image already import !"
	else
		echo "$1 image import start..."
		IMAGE_ID=`docker load -i ./$1.$2.tar`
		if [ -n "${IMAGE_ID}" ]; then
			echo -e "$1 image load success! ID[$IMAGE_ID]"
			tmp=($IMAGE_ID)
			echo ${tmp[3]}
			data=${tmp[3]}
			echo ${data:7:10}
			docker tag  ${data:7:10} $1:$2
	
		else
			echo -e "load $1 image failed! "
			printBlankRow
		fi
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
		image_load $APPP_NAME $APPP_VERSION && printBlankRow
		;;
	*)
		print_help && printBlankRow
		;;
esac




