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
######################################

# ----------------------------
# 使用方法函数
# ----------------------------
usage(){
    echo "使用方法 $CALLER -h -m 1 -s wiki -f \"testbucket1 testbucket2\""
    exit 1
}
# ----------------------------
# 结束运行函数
# ----------------------------
terminate(){
 dateTest=`date`
 echo "$CALLER 已终止: $dateTest"
 echo ""
 exit 1
}
# ----------------------------
# 清理环境函数
# ----------------------------
clearTestEnv(){
   `rm *.out *.report -rf` && echo "清理成功" || (echo "清理失败";terminate)
}
# ----------------------------
# 调用测试用例函数
# ----------------------------
runTest(){
   if [ ! -f "$1" ] ; then echo "非法文件$1";return 1; fi
   source $1
   echo "正在测试：$testDesc"
   let "testcase_total_count=$testcase_total_count+1"
   local testbucket="$1_testbucket"
   local preparebucket="$1_prepare"
   eval "$1_testbucket" > "$1_testbucket.out" && (let "testcase_success_count=$testcase_success_count+1"; return 0) || (let "testcase_fail_count=$testcase_fail_count+1";return 2)
}
# ----------------------------
# 生成测试报告函数
# ----------------------------
makeReport(){
   echo "make report"
}

# ----------------------------
# 主程序
# ----------------------------
CALLER=`basename $0`      # 主程序名称
# 加载共用文件
source emic_utils
# 检查输入参数个数
if [ $# -lt 1 ]
then
    usage
fi
# 处理输入参数
while getopts :hm:s:f: opt; do
    case $opt in
        h) usage;;
	m) emic_indexOf $OPTARG "1 2" && SENDMAILFLAG=$OPTARG ;;
        s) emic_indexOf $OPTARG "1 2" && UPDATAWIKIFLAG=$OPTARG ;;
	f) if [ -n "$OPTARG" ] ; then TESTFILS=$OPTARG ;fi;;
	\?) echo "未知参数";usage;;
    esac
done
# 检查输入参数
if [ -z "$TESTFILS" ] ; then echo "-f 没有测试文件";usage; fi

# 声明变量
testcase_total_count=0    # 测试用例总数
testcase_success_count=0  # 成功用例数
testcase_fail_count=0     # 失败用例数
# 清理环境
clearTestEnv
# 执行测试用例
for f in $TESTFILS
do
   runTest $f
done
# 生成测试报告
echo "total_count:$testcase_total_count"
echo "success_count:$testcase_success_count"
echo "fail_count:$testcase_total_count"

makeReport
# 发邮件
# 更新wiki
