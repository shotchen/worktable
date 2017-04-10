##############################
#    软件系统常用函数        #
#    author  cxl             #
##############################

DELETE_TK_RUNTIME="rm /var/pbx/tk/www/Talk/Runtime -rf"
DELETE_TK_CLI_RUNTIME="rm /var/pbx/tk/Cli/Runtime -rf"
DELETE_MT_RUNTIME="rm /var/pbx/mt/maintenance/Runtime -rf"
DELETE_MT_CLI_RUNTIME="rm /var/pbx/mt/CliForMt/Runtime -rf"

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

