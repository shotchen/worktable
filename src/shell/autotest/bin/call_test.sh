#!/bin/bash

######################################
# 
# 脚本名称: call_test.sh
#
# 目的:
#    1、测试命令行，遍历bucket目录下所有符合条件的文件，分别执行
#
# 注意事项：
#    使用方法 ./call_test.sh "test"
# 
# 作者: chenxuelin@emicnet.com
#    
######################################

reportTotal=0

for file in `ls ../bucket/test*.sh` 
do 
    ${file:-} 
done

echo "total:$reportTotal"