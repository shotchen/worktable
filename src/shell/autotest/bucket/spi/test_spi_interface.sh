#! /bin/bash

######################################
# 
# 脚本名称: test_spi_interface.sh
#
# 目的:
#    1、自动化测试SPI服务器所有接口
# 
# 注意事项：
#    
# 作者: chenxuelin@emicnet.com
# 
######################################

oneTimeSetUp(){
    . emic_conf
    . ../../src/emic_utils
    . ../../src/emic_log
    . ../../src/emic_command
    
    print_log "开始测试【SPI服务器接口】" info
    if [ "$use_db" = "true" ]
    then
        emic_echo_warn "nothing to do"
    else
        emic_echo_warn "nothing to say"
    fi 
}

testLogin(){
    print_log "开始测试登录接口"
    epName="我们是害虫[$province_name]"
    number="$areacode$switchNumber"
    maxMember=66
    paramter="Operate=createswitchboard&EpName=${epName}&Number=${number}&MaxMember=${maxMember}"
        
   emic_echo_warn ${paramter}
}

oneTimeTearDown(){
  echo 
  echo "--测试报告--"
  #echo "用例是否成功0成功1失败 :: ${__shunit_testSuccess}"
  echo "测试用例总数 :: ${__shunit_testsTotal}"
  echo "通过用例数 :: ${__shunit_testsPassed}"
  echo "失败用例数 :: ${__shunit_testsFailed}"
  echo "总功能点 :: ${__shunit_assertsTotal}"
  echo "通过功能点 :: ${__shunit_assertsPassed}"
  echo "失败功能点 :: ${__shunit_assertsFailed}"
  echo "跳过功能点 :: ${__shunit_assertsSkipped}" 
  echo "----------"
  echo 
}

# 加载shunit2开始测试
. ../../lib/shunit2