#! /bin/bash

######################################
# 
# 脚本名称: test_maintenance.sh
#
# 目的:
#    1、测试运维服务器接口
# 
# 注意事项：
#    
# 作者: chenxuelin@emicnet.com
# 
######################################


oneTimeSetUp(){
    startSkipping
    echo ""
}
setUp(){
    startSkipping
}
testEquals(){
    . ../conf/emic_conf
    echo "in test maintenance"
    assertEquals 'equals不相等出现的说明文字' 1 1
    echo ""
}

oneTimeTearDown(){
  echo 
  echo "__shunit_testSuccess :: ${__shunit_testSuccess}"
  echo "__shunit_testsTotal :: ${__shunit_testsTotal}"
  echo "__shunit_testsPassed :: ${__shunit_testsPassed}"
  echo "__shunit_testsFailed :: ${__shunit_testsFailed}"

  echo "__shunit_assertsTotal :: ${__shunit_assertsTotal}"
  echo "__shunit_assertsPassed :: ${__shunit_assertsPassed}"
  echo "__shunit_assertsFailed :: ${__shunit_assertsFailed}"
  echo "__shunit_assertsSkipped :: ${__shunit_assertsSkipped}"
  echo 
  let "reportTotal=reportTotal+${__shunit_testsTotal}"
  export reportTotal
}

# 加载shunit2开始测试
. ../lib/shunit2