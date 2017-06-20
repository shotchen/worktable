#!/bin/bash

######################################
# 
# 脚本名称: depend_test.sh
#
# 目的:
#    1、测试测试脚本服务器是否安装依赖包
#       apt-get install  php5-mcrypt libmcrypt4 libmcrypt-dev -y
#
# 注意事项：
#    使用方法 ./depend_test.sh
# 
# 作者: chenxuelin@emicnet.com
#    
######################################

dpkg -s jq >/dev/null
if [ $? -gt 0 ]
then
    apt-get install  jq -y
fi

dpkg -s xmlstarlet >/dev/null
if [ $? -gt 0 ]
then
    apt-get install  xmlstarlet -y
fi

exit 0