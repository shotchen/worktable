#!/bin/bash
##############################
#    自动测试脚本            #
#    author  cxl             #
##############################
source input.sh
source output.sh
source emic_system.sh
source mysql.sh

function usage(){
   emic_echo_info "请输入测试文件路径,例如./autotest.sh /tmp/bsstest.json"
}

if [ -z $1 ] ; then
   usage
   exit 1
fi
if [ ! -f "$1" ] ; then
   emic_echo_fail "$1文件不存在"
   exit 2
fi

emic_echo_info "读取测试数据"
cmd='cat $1 | jq ".testdata[].url"'
result=eval_cmd cmd
for row in $result
do
	echo "value is $row"
done
emic_echo_info "测试结果"
