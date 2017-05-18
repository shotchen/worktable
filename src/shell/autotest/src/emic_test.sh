######################################
# 
# 脚本名称: emic_test
#
# 目的:
#    1、shell测试基础方法类
#
# 注意事项：
#    不能单独执行，通过source包含
# 作者:cxl
# 
######################################

# 检查emic_log emic_utils
# emic_log、emic_utils是所有测试基类的基础，几乎所有方法都依赖于这个基类
source emic_log
source emic_utils

command -v emic_log >/dev/null 2>&1
result=$?
if [ $result -gt 0 ] 
then 
    echo -e "\E[1;31m无法完成测试，请包含测试基类emic_log\E[0m"
    exit 1
fi
command -v emic_utils >/dev/null 2>&1
result=$?
if [ $result -gt 0 ] 
then 
    echo -e "\E[1;31m无法完成测试，请包含测试基类emic_utils\E[0m"
    exit 1
fi

totalFile=0
totalCase=0
totalCaseTmp=0
totalFail=0
totalFailTmp=0
totalSuccess=0
totalSuccessTmp=0
status=1

# 测试emic_utils

## emic_echo_success
emic_echo_success "-- 开始测试emic_log方法" 
status=$?
let "totalFile++"
if [ $status -gt 0 ]
then
    echo -e "\E[1;31m 无法继续测试，emic_echo_success方法失败 \E[0m" 
    exit 2
else
    emic_echo_success "------ emic_echo_success 测试成功" 
fi
let "totalSuccessTmp++"

## emic_echo_fail
emic_echo_fail "------ emic_echo_fail 测试成功" 
status=$?
if [ $status -gt 0 ]
then
    echo -e "\E[1;31m 无法继续测试， emic_echo_fail 方法失败 \E[0m" 
    exit 2
fi
let "totalSuccessTmp++"

## emic_echo_info
emic_echo_info "------ emic_echo_info 测试成功" 
status=$?
if [ $status -gt 0 ]
then
    echo -e "\E[1;31m 无法继续测试， emic_echo_info 方法失败 \E[0m" 
    exit 2
fi
let "totalSuccessTmp++"

## emic_echo_warn
emic_echo_warn "------ emic_echo_warn 测试成功" 
status=$?
if [ $status -gt 0 ]
then
    echo -e "\E[1;31m 无法继续测试， emic_echo_warn 方法失败 \E[0m" 
    exit 2
fi
let "totalSuccessTmp++"

## emic_echo_debug
emic_echo_debug "------ emic_echo_debug 测试成功" 
status=$?
if [ $status -gt 0 ]
then
    echo -e "\E[1;31m 无法继续测试， emic_echo_debug 方法失败 \E[0m" 
    exit 2
fi
let "totalSuccessTmp++"


## 测试make_tmp_file方法
reportFile=`make_tmp_file ".report"` 
status=$?
if [ $status -gt 0 ]
then
    echo -e "\E[1;31m 无法继续测试， make_tmp_file 方法失败 \E[0m"
    exit 2
fi
let "totalSuccessTmp++"
emic_echo_success "------ make_tmp_file 测试成功" 
rm "$reportFile" -rf

## 测试emic_indexOf方法
testStr="test by cxl"
findMe="cxl"
findMe1="nofindme"
emic_indexOf "$findMe" "$testStr"
status=$?
if [ $status -gt 0 ]
then
    emic_echo_fail "------ 无法继续测试， emic_indexOf 方法失败 "
    exit 2
fi
let "totalSuccessTmp++"
emic_echo_success "------ emic_indexOf 查找成功测试成功" 

emic_indexOf "$findMe1" "$testStr"
status=$?
if [ $status -gt 0 ]
then
    emic_echo_success "------ emic_indexOf 查找失败测试成功 "   
    let "totalSuccessTmp++"
else
    emic_echo_fail "------ emic_indexOf 查找失败测试失败 "   
    let "totalFailTmp++"
fi


## 测试 command_exist 方法
command_exist "ls"
status=$?
if [ $status -gt 0 ]
then
    emic_echo_fail "------ command_exist 命令返回成功 测试失败 "   
    let "totalFailTmp++"    
else
    emic_echo_success "------ command_exist 命令返回成功 测试成功 "   
    let "totalSuccessTmp++"
fi

command_exist "lscxl123"
status=$?
if [ $status -gt 0 ]
then
    emic_echo_success "------ command_exist 命令返回失败 测试成功 "   
    let "totalSuccessTmp++"
else
    emic_echo_fail "------ command_exist 命令返回失败 测试失败 "   
    let "totalFailTmp++"
fi

## 测试 emic_strtoupper 方法
testStr="abcd"
result=`emic_strtoupper "$testStr"`
status=$?
if [ "$status" -gt 0 ]
then
    emic_echo_fail "------ emic_strtoupper 不存在测试失败 "
    let "totalFailTmp++"
elif [ "$result" != "ABCD" ]
then
    emic_echo_fail "------ emic_strtoupper 测试失败 "
    let "totalFailTmp++"    
else
    emic_echo_success "------ emic_strtoupper 测试成功 "
    let "totalSuccessTmp++"
fi

## 测试 emic_strtolow 方法
testStr="ABCDE"
result=`emic_strtolow "$testStr"`
status=$?
if [ "$status" -gt 0 ]
then
    emic_echo_fail "------ emic_strtolow 不存在测试失败 "
    let "totalFailTmp++"
elif [ "$result" != "abcde" ]
then
    emic_echo_fail "------ emic_strtolow 测试失败 "
    let "totalFailTmp++"    
else
    emic_echo_success "------ emic_strtolow 测试成功 "
    let "totalSuccessTmp++"
fi

let "totalCaseTmp=$totalSuccessTmp+$totalFailTmp"
let "totalSuccess=$totalSuccess+$totalSuccessTmp"
let "totalFail=$totalFail+$totalFailTmp"
let "totalCase=$totalSuccess+$totalFail"
echo "******"
emic_echo_info "测试文件：emic_utils -- 测试总用例：$totalCaseTmp --成功：$totalSuccessTmp --失败：$totalFailTmp"

totalCaseTmp=0
totalSuccessTmp=0
totalFailTmp=0

emic_echo_info "--开始测试emic_log"
let "totalFile++"

## 测试 emic_log 方法
emic_log_file="emic_log_file.log"
rm "$emic_log_file" -rf
emic_log "cxl test" "debug"
status=$?
if [ "$status" -gt 0 ]
then
    emic_echo_fail "------ emic_log 测试失败 "
    let "totalFailTmp++" 
else
    cat "$emic_log_file" | grep 'cxl' | grep 'DEBUG' >/dev/null && status=0 || status=1
    if [ "$status" -gt 0 ]
    then
        emic_echo_fail "------ emic_log 未找到字符串测试失败 "
        let "totalFailTmp++" 
    else
        emic_echo_success "------ emic_log 测试成功 "
        let "totalSuccessTmp++" 
    fi
fi

### 测试print_log方法
rm "$emic_log_file" -rf
print_log "cxl test" "error"
status=$?
if [ "$status" -gt 0 ]
then
    emic_echo_fail "------ print_log 测试失败 "
    let "totalFailTmp++" 
else
    cat "$emic_log_file" | grep 'cxl' | grep 'ERROR' >/dev/null && status=0 || status=1
    if [ "$status" -gt 0 ]
    then
        emic_echo_fail "------ print_log 未找到字符串测试失败 "
        let "totalFailTmp++" 
    else
        emic_echo_success "------ print_log 测试成功 "
        let "totalSuccessTmp++" 
    fi
fi

let "totalCaseTmp=$totalSuccessTmp+$totalFailTmp"
let "totalSuccess=$totalSuccess+$totalSuccessTmp"
let "totalFail=$totalFail+$totalFailTmp"
let "totalCase=$totalSuccess+$totalFail"
echo "******"
emic_echo_info "测试文件：emic_log -- 测试总用例：$totalCaseTmp --成功：$totalSuccessTmp --失败：$totalFailTmp"
totalCaseTmp=0
totalSuccessTmp=0
totalFailTmp=0

## 测试 emic_command 方法
emic_echo_info "--开始测试emic_command"
source emic_command
let "totalFile++"

command_exist emic_command && status=0 || status=1
if [ "$status" -gt 0 ]
then
    emic_echo_fail "------ emic_command 不存在 测试失败 "
    let "totalFailTmp++" 
else
    emic_eval_command "ls -la" && status=0 || status=1
    if [ "$status" -gt 0 ]
    then
        emic_echo_fail "------ emic_eval_command 测试失败 "
        let "totalFailTmp++"
    else
        emic_echo_success "------ emic_eval_command 测试成功 "
        let "totalSuccessTmp++"
    fi
    
    emic_eval_command "nocommand -la" && status=0 || status=1
    if [ "$status" -gt 0 ]
    then
        emic_echo_success "------ emic_eval_command 测试(命令失败)成功 "
        let "totalSuccessTmp++"
    else
        emic_echo_fail "------ emic_eval_command 测试(命令失败)失败 "
        let "totalFailTmp++"    
    fi
fi

let "totalCaseTmp=$totalSuccessTmp+$totalFailTmp"
let "totalSuccess=$totalSuccess+$totalSuccessTmp"
let "totalFail=$totalFail+$totalFailTmp"
let "totalCase=$totalSuccess+$totalFail"
echo "******"
emic_echo_info "测试文件：emic_command -- 测试总用例：$totalCaseTmp --成功：$totalSuccessTmp --失败：$totalFailTmp"
totalCaseTmp=0
totalSuccessTmp=0
totalFailTmp=0

## 测试 emic_crypt 方法
emic_echo_info "--开始测试 emic_crypt"
source emic_crypt
let "totalFile++"

command_exist emic_crypt && status=0 || status=1
if [ "$status" -gt 0 ]
then
    emic_echo_fail "------ emic_crypt 不存在 测试失败 "
    let "totalFailTmp++" 
else
    md5Str=`md5_str "1234567"` && status=0 || status=1
    if [ "$status" -gt 0 ]
    then
        emic_echo_fail "------ md5_str 不存在 测试失败 "
        let "totalFailTmp++"
    elif [ "$md5Str" = "fcea920f7412b5da7be0cf42b8c93759" ]
    then
        emic_echo_success "------ md5_str 测试成功 "
        let "totalSuccessTmp++"
    else
        emic_echo_fail "------ md5_str 测试失败 "
        let "totalFailTmp++"
    fi 

    encryptStr=`cq_encrypt_str "1234567" "226a89e66d0dcc79c9673150fa176001"` && status=0 || status=1
    if [ "$status" -gt 0 ]
    then
        emic_echo_fail "------ cq_encrypt_str 不存在 测试失败 "
        let "totalFailTmp++"
    elif [ "$encryptStr" = "196D7E3754C5814D4C868C38E951F588" ]
    then
        emic_echo_success "------ cq_encrypt_str 测试成功 "
        let "totalSuccessTmp++"
    else
        emic_echo_fail "------ cq_encrypt_str 测试失败 "
        let "totalFailTmp++"
    fi 

    decryptStr=`cq_decrypt_str "196D7E3754C5814D4C868C38E951F588" "226a89e66d0dcc79c9673150fa176001"` && status=0 || status=1
    if [ "$status" -gt 0 ]
    then
        emic_echo_fail "------ cq_decrypt_str 不存在 测试失败 "
        let "totalFailTmp++"
    elif [ "$decryptStr" = "1234567" ]
    then
        emic_echo_success "------ cq_decrypt_str 测试成功 "
        let "totalSuccessTmp++"
    else
        emic_echo_fail "------ cq_decrypt_str 测试失败 "
        let "totalFailTmp++"
    fi 

    gzipStr=`cq_gzip_str "1234567"` && status=0 || status=1
    if [ "$status" -gt 0 ]
    then
        emic_echo_fail "------ cq_gzip_str 不存在 测试失败 "
        let "totalFailTmp++"
    elif [ "$gzipStr" = "H4sIAAAAAAAAAzM0MjYxNTMHAJ9pA1AHAAAA" ]
    then
        emic_echo_success "------ cq_gzip_str 测试成功 "
        let "totalSuccessTmp++"
    else
        echo $gzipStr
        emic_echo_fail "------ cq_gzip_str 测试失败 "
        let "totalFailTmp++"
    fi 

    unzipStr=`cq_unzip_str "H4sIAAAAAAAAAzM0MjYxNTMHAJ9pA1AHAAAA"` && status=0 || status=1
    if [ "$status" -gt 0 ]
    then
        emic_echo_fail "------ cq_unzip_str 不存在 测试失败 "
        let "totalFailTmp++"
    elif [ "$unzipStr" = "1234567" ]
    then
        emic_echo_success "------ cq_unzip_str 测试成功 "
        let "totalSuccessTmp++"
    else
        emic_echo_fail "------ cq_unzip_str 测试失败 "
        let "totalFailTmp++"
    fi 
fi

let "totalCaseTmp=$totalSuccessTmp+$totalFailTmp"
let "totalSuccess=$totalSuccess+$totalSuccessTmp"
let "totalFail=$totalFail+$totalFailTmp"
let "totalCase=$totalSuccess+$totalFail"
echo "******"
emic_echo_info "测试文件：emic_crypt -- 测试总用例：$totalCaseTmp --成功：$totalSuccessTmp --失败：$totalFailTmp"
totalCaseTmp=0
totalSuccessTmp=0
totalFailTmp=0

echo "******"
emic_echo_info "测试文件数：$totalFile -- 测试总用例：$totalCase --成功：$totalSuccess --失败：$totalFail"

# 返回测试情况
if [ "$totalCase" -gt 0 ] && [ "$totalFail" -gt 0 ] ; then status=1; else status=0; fi
exit $status