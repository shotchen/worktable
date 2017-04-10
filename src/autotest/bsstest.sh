#!/bin/bash
RED_COLOR='\E[1;31m'  #红
GREEN_COLOR='\E[1;32m' #绿
YELOW_COLOR='\E[1;33m' #黄
BLUE_COLOR='\E[1;34m'  #蓝
PINK='\E[1;35m'      #粉红
RES='\E[0m'

#if [ $(whoami) = "root" ] ; then
#   echo -e "**** ${BLUE_COLOR}重启apache服务器${RES} ****" 
#   $restart_apache_cmd  && echoSuccessStr "$restart_apache_cmd" || echoErrorStr "$restart_apache_cmd"
#else
   #非root允许脚本，提醒用户手动安装 
#   echoDangerStr "非root用户请手动执行重启apache服务器:$restart_apache_cmd"
#fi

function getStatusStr(){
    if [ "$status" == "" ]
    then
       status=$?
    fi
   
    if [ $status -gt 0 ] 
    then 
        echo -e "${RED_COLOR}NOTOK${RES}"
    else
        echo -e "${GREEN_COLOR}OK${RES}"
    fi
    return 0
}

function echoSuccessStr(){
   echo -e "** $1 [${GREEN_COLOR}OK${RES}] **"
}

function echoErrorStr(){
   echo -e "** $1 [${RED_COLOR}NOTOK${RES}] **"
}

function echoDangerStr(){
   echo -e "**  [${PINK}$1${RES}] **"
}

function copyFile(){
   cp $1 $2
   status=$?
   echo "** cp $1 $2 ------- [$(getStatusStr $status)] **"
}

function deleteRuntime(){
    rm /var/pbx/mt/CliForMt/Runtime -rf
    status=$?
    echo "** rm /var/pbx/mt/CliForMt/Runtime -rf ------ [$(getStatusStr status)] **"
    rm /var/pbx/mt/maintenance/Runtime -rf
    status=$?
    echo "** rm /var/pbx/mt/maintenance/Runtime -rf ------ [$(getStatusStr status)] **"
}
function executeMysqlCommand(){
    mysql -uroot -p"C1oudP8x&2017" --local-infile=1 -e "$1"  
    status=$?
    echo "** mysql -uroot -p\"C1oudP8x&2017\" --local-infile=1 -e \"$1\" ------ [$(getStatusStr status)] **"
}

cur_directory=`pwd`
apt_cmd='apt-get install  php5-mcrypt libmcrypt4 libmcrypt-dev -y'
chown_cmd='chown www-data:www-data *.php'
lsrole_cmd="ls -l BssAction.class.php|grep www-data"
restart_apache_cmd='service apache2 restart'

echo -e "**** ${BLUE_COLOR}安装mcrpyt支持${RES} ****" 


if [ $(whoami) = "root" ] ; then
   echo -e "**** ${BLUE_COLOR}安装mcrpyt支持${RES} ****" 
   $apt_cmd  && echoSuccessStr "$apt_cmd" || (echoErrorStr "$apt_cmd" && exit 1)
   echo -e "**** ${BLUE_COLOR}修改安装文件归属用户为www-data${RES} ****" 
   $chown_cmd  && echoSuccessStr "$chown_cmd" || (echoErrorStr "$chown_cmd" && exit 1) 
else
    #非root允许脚本，提醒用户手动安装 
    echoDangerStr "非root用户请手动执行安装mcrpyt支持:$apt_cmd，修改文件权限命令：$chown_cmd"
fi

eval $lsrole_cmd && filerole=0 || filerole=1
if [ $filerole -gt 0 ] ; then
   echoErrorStr "$lsrole_cmd"
   echoDangerStr "php文件权限不正确，请调用$chown_cmd"
   exit 2
else
   echoSuccessStr "$lsrole_cmd"
   echo -e "**** ${BLUE_COLOR}备份php文件${RES} ****" 
   bak_dir=`date +%Y%m%d%H%M%S`
   mkdir $bak_dir && echoSuccessStr "mkdir $bak_dir" || echoErrorStr "mkdir $bak_dir"
   copyFile /var/pbx/mt/maintenance/Lib/Action/NoAuthAction.class.php $bak_dir/NoAuthAction.class.php.bak
   copyFile /var/pbx/mt/maintenance/Lib/Action/Api/BssAction.class.php $bak_dir/BssAction.class.php.bak
   copyFile /var/pbx/mt/maintenance/Lib/Model/BssOperationModel.class.php $bak_dir/BssOperationModel.class.php.bak
   copyFile /var/pbx/mt/maintenance/Lib/Utils/CryptAES.class.php $bak_dir/CryptAES.class.php.bak
   copyFile /var/pbx/mt/maintenance/Lib/Utils/GZip.class.php $bak_dir/GZip.class.php.bak
   echo -e "**** ${BLUE_COLOR}拷贝php文件到指定目录${RES} ****" 
   copyFile NoAuthAction.class.php /var/pbx/mt/maintenance/Lib/Action/NoAuthAction.class.php
   copyFile BssAction.class.php /var/pbx/mt/maintenance/Lib/Action/Api/BssAction.class.php
   copyFile BssOperationModel.class.php /var/pbx/mt/maintenance/Lib/Model/BssOperationModel.class.php
   copyFile CryptAES.class.php /var/pbx/mt/maintenance/Lib/Utils/CryptAES.class.php
   copyFile GZip.class.php /var/pbx/mt/maintenance/Lib/Utils/GZip.class.php
fi

echo -e "**** ${BLUE_COLOR}删除缓存文件${RES} ****" 
deleteRuntime



exit 0

