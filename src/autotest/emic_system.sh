##############################
#    软件系统常用函数        #
#    author  cxl             #
##############################

DELETE_TK_RUNTIME="rm /var/pbx/tk/www/Talk/Runtime -rf"
DELETE_TK_CLI_RUNTIME="rm /var/pbx/tk/Cli/Runtime -rf"
DELETE_MT_RUNTIME="rm /var/pbx/mt/maintenance/Runtime -rf"
DELETE_MT_CLI_RUNTIME="rm /var/pbx/mt/CliForMt/Runtime -rf"
BSS_REQUEST_URL="http://127.0.0.1:1046/Api/Bss/bssHttp" 
CQ_ENCRYPT_CMD="php /var/pbx/mt/CliForMt/cli.php Test getZipedStr"

# 删除运维服务器缓存
function deleteMtRuntime(){
   eval_cmd "$DELETE_TK_RUNTIME"
   eval_cmd "$DELETE_TK_CLI_RUNTIME"
}
# 删除企业服务器缓存
function deleteTalkRuntime(){
   eval_cmd "$DELETE_MT_RUNTIME"
   eval_cmd "$DELETE_MT_CLI_RUNTIME"
}
# 删除云总机服务器缓存
function deleteYzjRuntime(){
   deleteMtRuntime
   deleteTalkRuntime
}
# curl请求
function curlRequest(){   
    if [ $# -gt 2 ] ; then 
       curlRequest="curl $1 $2 $3 $4"
       eval_cmd "$curlRequest"
    else
       emic_echo_fail "curlRequest参数非法"
    fi  
}
# 获取加密字符串
function getEncryptStr(){   
    if [ $# -gt 2 ] ; then 
       command="$CQ_ENCRYPT_CMD $1 $2"
       eval_cmd "$command"
    else
       emic_echo_fail "getEncryptStr参数非法"
    fi  
}