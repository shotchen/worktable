#!/bin/bash

######################################
# 
# 脚本名称: emic_auto_test.sh
#
# 目的:
#    1、自动加载测试文件
#    2、执行测试文件中的标准测试
#    3、生成测试报告
#
# 注意事项：
#    使用方法 emic_auto_test.sh [options] "testbucket1 testbucket2"
#    [options] : -h help（帮助信息）
#                -f file（加载测试文件路径)
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
    exit 1
}
# ----------------------------
# 结束运行函数
# ----------------------------
terminate(){
    dateTest=`date +'%Y-%m-%d %H:%M:%S'`
    local msg="$CALLER 已终止: $dateTest"
    echo -e $msg
    exit 1
}
# ----------------------------
# 检查运行环境函数
# ----------------------------
checkEnv(){
    local checkMsg=""
    command -v "emic_utils" >/dev/null 2>&1 || checkMsg="本程序需要emic_utils,请包含该文件"
    command -v "emic_log" >/dev/null 2>&1 || checkMsg="$checkMsg 本程序需要emic_log,请包含该文件"
    command -v "emic_command" >/dev/null 2>&1 || checkMsg="$checkMsg 本程序需要emic_command,请包含该文件"
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
    local status=0
    emic_eval_command "rm *.report *.tmp  -rf" && status=0 || status=1
    if [ $status != 0 ]
    then 
        print_log "清理环境失败" "error"
        terminate
    else
        print_log "清理环境成功" "info"
    fi
    return $status
}
# ----------------------------
# 调用测试用例函数
# ----------------------------
runTest(){
    if [ ! -f "$1" ] ; then print_log "非法文件$1";return 1; fi
    local status=0
    source "$1"
    let "totalFile++"
    # 执行与文件名同名函数，检查依赖或初始化
    eval "$1" && status=0 || status=1
    if [ $status  -gt 0 ]
    then
        print_log "执行命令【$1】失败" "error" 
        return 1
    else
        print_log "执行命令【$1】成功" "info"  
    fi
    command_exist "$1_testbucket" && status=0 || status=1
    if [ $status  -gt 0 ]
    then
        print_log "测试桶命令【$1_testbucket】不存在" "error" 
        let "totalFailTmp++"
        return 1
    fi
    eval "$1_testbucket" && status=0 || status=1
    if [ $status  -gt 0 ]
    then
        print_log "执行命令【$1_testbucket】失败" "error" 
        return 1
    else
        print_log "执行命令【$1_testbucket】成功" "info"  
    fi
    return $status
}
# ----------------------------
# 生成测试报告函数
# 生成json数据
# ----------------------------
makeReport(){
   print_log "正在生成测试报告$report_file"
   echo "总用例个数:$testcase_total_count" >> $report_file
   echo "成功用例个数:$testcase_success_count" >> $report_file
   echo "失败用例个数:$testcase_fail_count" >> $report_file
   print_log "结束生成测试报告$report_file"
}

# 声明变量
CALLER=`basename $0`      # 主程序名称
current_dir=`pwd`         # 当前目录
# 加载共用文件
source emic_utils
source emic_log
source emic_command
source emic_crypt
source emic_conf

# 检查必要文件
checkEnv
# 清理临时文件
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
        m) emic_indexOf $OPTARG "1 2" && is_sendmail="$OPTARG" || usage ;;
        s) emic_indexOf $OPTARG "1 2" && is_update_wiki="$OPTARG"  || usage ;;
        f) if [ -n "$OPTARG" ] ; then testFiles="$OPTARG" ; else usage; fi;;
        \?) emic_echo_fail "未知参数";usage;;
    esac
done

# 检查参数是否合理
if [ -z "$testFiles" ]
then
    emic_echo_fail "没有找到需测试的文件 -f 参数必需有值"
    usage
fi
# 生成reportFile地址
#reportFile=`make_tmp_file ".report"`    # 测试报告文件
#reportStr=""                            # 报告文本 json 格式

# 设置测试变量
totalFile=0             # 测试文件总数
totalCase=0             # 测试总用例数
totalCaseTmp=0          # 当前测试文件测试用例数
totalFail=0             # 测试失败用例数
totalFailTmp=0          # 当前测试文件失败用例数
totalSuccess=0          # 测试成功用例数
totalSuccessTmp=0       # 当前测试文件成功用例数
status=0                # 测试过程中返回的状态
# 开始测试
dateTest=`date +'%Y-%m-%d %H:%M:%S'`
print_log "测试开始$dateTest" info

for testFile in $testFiles
do
    totalCaseTmp=0
    totalSuccessTmp=0
    totalFailTmp=0
    runTest "$testFile" && status=0 || status=1
    if [ $status  -gt 0 ]
    then
        print_log "调用文件【$testFile】失败" "error" 
    else
        print_log "调用文件【$testFile】成功" "info"  
    fi
    let "totalCaseTmp=$totalSuccessTmp+$totalFailTmp"
    let "totalSuccess=$totalSuccess+$totalSuccessTmp"
    let "totalFail=$totalFail+$totalFailTmp"
    let "totalCase=$totalSuccess+$totalFail"
    echo ""
    print_log "测试文件：$testFile -- 测试总用例：$totalCaseTmp --成功：$totalSuccessTmp --失败：$totalFailTmp" "info"
    echo ""
done

dateTest=`date +'%Y-%m-%d %H:%M:%S'`
echo ""
print_log "测试文件数：$totalFile -- 测试总用例：$totalCase --成功：$totalSuccess --失败：$totalFail" "info"
echo ""
print_log "测试结束$dateTest" info
