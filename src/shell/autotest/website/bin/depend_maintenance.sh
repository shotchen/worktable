#!/bin/bash

######################################
# 
# 脚本名称: depend_maintenance.sh
#
# 目的:
#    1、测试运维服务是否安装依赖包
#       apt-get install  php5-mcrypt libmcrypt4 libmcrypt-dev -y
#
# 注意事项：
#    使用方法 ./depend_maintenance.sh
# 
# 作者: chenxuelin@emicnet.com
#    
#
######################################

dpkg -s php5-mcrypt 
if [ $? -gt 0 ]
then
    apt-get install  php5-mcrypt -y
fi

dpkg -s libmcrypt4 
if [ $? -gt 0 ]
then
    apt-get install  libmcrypt4 -y
fi

dpkg -s libmcrypt-dev
if [ $? -gt 0 ]
then
    apt-get install  libmcrypt-dev -y
fi

exit 0