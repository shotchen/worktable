#!/bin/bash

######################################
# 
# 脚本名称: loadtestbucket
#
# 目的:
#    1、加载测试用例
#    2、返回测试结果
#    3、生成测试报告
#
# 注意事项：
#    使用方法 loadtestbucket.sh [options] "testbucket1 testbucket2"
#    [options] : -h help（帮助信息）
#
# 返回：
#    0、执行成功
#    1、执行失败
# 
# 作者:cxl
#    
#
######################################

# ----------------------------
# 使用方法函数
# ----------------------------
usage(){
    echo "使用方法 $CALLER -h -m 1 -s wiki -f \"testbucket1 testbucket2\" "
    echo "参数详解："
    echo " -h : 帮助"
    echo " -m : 是否发送邮件0不发送1发送 缺省不发送"
    echo " -s : 是否记录wiki0不记录1记录 缺省不记录"
    echo " -f : 测试用例文件名或文件路径，不能为空"
    echo ""
    echo "依赖命令：openssl tr awk sed od "
    exit 1
}
# ----------------------------
# 结束运行函数
# ----------------------------
terminate(){
    dateTest=`date +'%Y-%m-%d %H:%M:%S'`
    local msg="$CALLER 已终止: $dateTest"
    echo -e $msg
    echo ""
    exit 1
}
# ----------------------------
# 检查运行环境函数
# ----------------------------
checkEnv(){
    local checkMsg=""
    command -v "emic_utils" >/dev/null 2>&1 || checkMsg="本程序需要emic_utils,请包含该文件"
    command -v "emic_log" >/dev/null 2>&1 || checkMsg="$checkMsg 本程序需要emic_log,请包含该文件"
    if [ -n "$checkMsg" ]
    then
        for msg in $checkMsg
	do
	    echo -e "$msg"
	done
	terminate
    fi
}
# ----------------------------
# 清理环境函数
# .report 生成的报告文件
# .log 打印的log文件
# ----------------------------
clearEnv(){
   local clear_flag=0
   #eval_cmd "ls -la"
   eval_cmd "rm *.report *.log  -rf" && clear_flag=0 || clear_flag=1
   if [ $clear_flag != 0 ]
   then 
      print_log "清理环境失败" "error"
      terminate
   fi
}
# ----------------------------
# 调用测试用例函数
# ----------------------------
runTest(){
   if [ ! -f "$1" ] ; then emic_echo_fail "非法文件$1";return 1; fi
   source $1
   let "testcase_total_count=$testcase_total_count+1"
   local testbucket="$1_testbucket"
   local preparebucket="$1_prepare"
   command_exist "preparebucket" && eval_cmd "$preparebucket" 
   eval_cmd "$testbucket"  && (let "testcase_success_count=$testcase_success_count+1"; return 0) || (let "testcase_fail_count=$testcase_fail_count+1";return 2)  
}
# ----------------------------
# 生成测试报告函数
# ----------------------------
makeReport(){
   print_log "正在生成测试报告$report_file"
   echo "总用例个数:$testcase_total_count" >> $report_file
   echo "成功用例个数:$testcase_success_count" >> $report_file
   echo "失败用例个数:$testcase_fail_count" >> $report_file
   print_log "结束生成测试报告$report_file"
}

# ----------------------------
# 主程序
# ----------------------------
CALLER=`basename $0`      # 主程序名称
CURRENTDIR=`pwd`         # 当前运行目录
emic_log_file="$CURRENTDIR/log.log"
report_file="$CURRENTDIR/report.report"

# 加载共用文件
source emic_utils
source emic_log
source loadtestbucket.conf

# 检查运行依赖
checkEnv

# 清理环境
clearEnv

# 检查输入参数个数
if [ $# -lt 1 ]
then
    usage
fi

# 处理输入参数
while getopts :hm:s:f: opt; do
    case $opt in
        h) usage;;
	m) emic_indexOf $OPTARG "1 2" && is_sendmail=$OPTARG ;;
        s) emic_indexOf $OPTARG "1 2" && is_update_wiki=$OPTARG ;;
	f) if [ -n "$OPTARG" ] ; then TESTFILS=$OPTARG ;fi;;
	\?) emic_echo_fail "未知参数";usage;;
    esac
done

# 检查输入参数
if [ -z "$TESTFILS" ] ; then echo "-f 没有测试文件";usage; fi

# 声明变量
testcase_total_count=0    # 测试用例总数
testcase_success_count=0  # 成功用例数
testcase_fail_count=0     # 失败用例数
# 执行测试用例
for f in $TESTFILS
do
   runTest $f 
done

# 生成测试报告
makeReport
# 发邮件
# 更新wiki
