#! /bin/bash

######################################
# 
# 脚本名称: test_bss_jiangsu.sh
#
# 目的:
#    1、测试江苏bss用例
# 
# 注意事项：
#    
# 作者: chenxuelin@emicnet.com
# 
######################################

oneTimeSetUp(){
    . ../conf/emic_conf
    . ../src/emic_utils
    . ../src/emic_log
    . ../src/emic_command
    . ../src/emic_crypt
    . ../src/emic_model
    
    province="jiangsu"
    province_name=`emic_get_province "$province"`
    areacode=`emic_get_areacode "$province"`
    bssUrl="http://${maintenance_ip}:1046/Api/Bss/bssHttp"
    switchNumber='11111111'
    directNumber='22222222'
    meetingNumber='33333333'
   
    print_log "开始测试【$province_name】BSS命令" info
    if [ "$use_db" = "true" ]
    then
        emic_echo_warn "先在mysql里设置允许远程访问的权限，在运维服务器和企业服务器的mysql中执行一下语句，授权测试机器访问mysql数据库"
        emic_echo_warn "grant all on *.* to root@10.0.0.40 identified by 'C1oudP8x&2017' with grant option;"
         # 测试是否能远程访问数据库
        update_param_province "$province" || exit 1    
        print_log "连接mysql正常" info
    else
        emic_echo_warn "请确认已将运维和企业服务器设置为测试省份$province"
    fi 
    # 重庆加解密key
    md5Str=`md5_str "$cq_bss_pwd" "true"`
}

testCreateSwitchBoard(){
    print_log "开始测试创建总机操作"
    epName="我们是害虫[$province_name]"
    number="$areacode$switchNumber"
    maxMember=66
    paramter="Operate=createswitchboard&EpName=${epName}&Number=${number}&PlanCode=99033079"
        
    sendBssRequest "$paramter" && status=0 || status=1
    if [ $status -gt 0 ] 
    then
        fail "【新装总机】失败"
        startSkipping
        return $status
    fi
    # sleep 5秒，确保命令已执行完毕
    sleep 5 
    # 检查数据库是否正常
    if [ "$use_db" = "true" ]
    then
        checkNumberExist  "$areacode" "$switchNumber" && status=0 || status=1
        if [ $status -gt 0 ] 
        then
            fail "【新装总机】失败"
            return $status
        fi   
    fi
    print_log "【新装总机】成功" info
    assertSame 1 1
}

testCreateDirectNumber(){
    print_log "开始测试创建直线操作"
    number="$areacode$directNumber"
    switch_number="$areacode$switchNumber"
    paramter="Operate=createdirectnumber&Number=${number}&SwitchNumber=${switch_number}"
    
    sendBssRequest "$paramter" && status=0 || status=1
    if [ $status -gt 0 ] 
    then
        fail "【新装直线】失败"
        startSkipping
        return $status
    fi
    # sleep 5秒，确保命令已执行完毕
    sleep 5 
    # 检查数据库是否正常
    if [ "$use_db" = "true" ]
    then
        checkNumberExist  "$areacode" "$directNumber" && status=0 || status=1
        if [ $status -gt 0 ] 
        then
            fail "【新装直线】失败"
            return $status
        fi  
    fi
    print_log "【新装直线】成功" info
    assertSame 1 1
}

testCreateMeetBridgeNumber(){
    print_log "开始测试新装会议操作"
    number="$areacode$meetingNumber"
    switch_number="$areacode$switchNumber"
    paramter="Operate=createmeetbridgenumber&Number=${number}&SwitchNumber=${switch_number}&PlanCode=99033160"
      
    sendBssRequest "$paramter" && status=0 || status=1
    if [ $status -gt 0 ] 
    then
        fail "【新装会议】失败"
        startSkipping
        return $status
    fi
     # sleep 5秒，确保命令已执行完毕
    sleep 5 
    # 检查数据库是否正常
    if [ "$use_db" = "true" ]
    then
        checkNumberExist  "$areacode" "$meetingNumber" && status=0 || status=1
        if [ $status -gt 0 ] 
        then
            fail "【新装会议】失败"
            return $status
        fi  
    fi
    print_log "【新装会议】成功" info
    assertSame 1 1
}

testModifyMaxMember(){
    startSkipping
    return 0
    print_log "开始测试修改最大用户数操作"
    switch_number="$areacode$switchNumber"
    maxMember=33
    paramter="Operate=modifymaxmember&Number=${switch_number}&MaxMember=${maxMember}"
  
    sendBssRequest "$paramter" && status=0 || status=1
    if [ $status -gt 0 ] 
    then
        fail "【修改最大用户数】失败"
        startSkipping
        return $status
    fi
    # sleep 5秒，确保命令已执行完毕
    sleep 5 
    # 检查数据库是否正常
    if [ "$use_db" = "true" ]
    then
        curMaxMember=`getEpMaxMember "$areacode" "$switchNumber"`
        if [ "$maxMember" != "$curMaxMember" ] 
        then
            fail "【修改最大用户数】失败,当前：${curMaxMember},期望:${maxMember}"
            return $status
        fi   
    fi
    print_log "【修改最大用户数】成功" info
    assertSame 1 1
}

testModifyNumberStatusMulti(){
    startSkipping
    return 0
    print_log "开始测试修改多个号码状态操作"
    number="$areacode$meetingNumber,$areacode$directNumber"
    numberStatus="1"
    paramter="Operate=modifyNumberStatus&Number=${number}&Status=${numberStatus}"

    sendBssRequest "$paramter" && status=0 || status=1
    if [ $status -gt 0 ] 
    then
        fail "【修改多个号码状态】失败"
        startSkipping
        return $status
    fi
    # sleep 10秒，确保命令已执行完毕,根据操作号码格式灵活调整休眠时间
    sleep 10 
    # 检查数据库是否正常
    if [ "$use_db" = "true" ]
    then
        local curMeetingNumberStatus=`getNumberStatus "$areacode" "$meetingNumber"`
        local statusTmp=0
        if [ "$numberStatus" != "$curMeetingNumberStatus" ] 
        then
            fail "【修改会议号码状态】失败,当前：${curMeetingNumberStatus},期望:${numberStatus}"
            statusTmp=1
        else
            print_log "【修改会议号码状态】成功" info
            assertSame 1 1
        fi 
        local curDirectNumberStatus=`getNumberStatus "$areacode" "$directNumber"`
        local statusTmp=0
        if [ "$numberStatus" != "$curDirectNumberStatus" ] 
        then
            fail "【修改直线号码状态】失败,当前：${curDirectNumberStatus},期望:${numberStatus}"
            statusTmp=1
        else
            print_log "【修改直线号码状态】成功" info
            assertSame 1 1
        fi 
        return $statusTmp
    fi
    print_log "【修改多个号码状态】成功" info
    assertSame 1 1
}

testDeleteNumber(){
    print_log "开始测试删除会议号码操作"
    number="$areacode$meetingNumber"
    paramter="Operate=deletenumber&Number=${number}"
    
    sendBssRequest "$paramter" && status=0 || status=1
    # sleep 5秒，确保命令已执行完毕
    sleep 5 
    if [ $status -gt 0 ] 
    then
        fail "【删除会议号码】失败"
    else
        # 检查数据库是否正常
        if [ "$use_db" = "true" ]
        then
            checkNumberExist  "$areacode" "$meetingNumber" && status=0 || status=1
            if [ $status -gt 0 ] 
            then
                print_log "【删除会议号码】成功" info
                assertSame 1 1
            else
                fail "【删除会议号码】失败"   
            fi 
        else
            print_log "【删除会议号码】成功" info
            assertSame 1 1
        fi
    fi
   
    print_log "开始测试删除直线号码操作"
    number="$areacode$directNumber"
    paramter="Operate=deletenumber&Number=${number}"
    
    sendBssRequest "$paramter" && status=0 || status=1
    # sleep 5秒，确保命令已执行完毕
    sleep 5 
    if [ $status -gt 0 ] 
    then
        fail "【删除直线号码】失败"
    else
        if [ "$use_db" = "true" ]
        then            
            checkNumberExist  "$areacode" "$directNumber" && status=0 || status=1
            if [ $status -gt 0 ] 
            then
                print_log "【删除直线号码】成功" info
                assertSame 1 1
            else
                fail "【删除直线号码】失败"   
            fi 
        else
            print_log "【删除直线号码】成功" info
            assertSame 1 1
        fi
    fi
    # 检查数据库是否正常
    
    print_log "开始测试删除总机号码操作"
    number="$areacode$switchNumber"
    paramter="Operate=deletenumber&Number=${number}"

    sendBssRequest "$paramter" && status=0 || status=1
    # sleep 5秒，确保命令已执行完毕
    sleep 5 
    if [ $status -gt 0 ] 
    then
        fail "【删除总机号码】失败"
    else
        if [ "$use_db" = "true" ]
        then
            checkNumberExist  "$areacode" "$switchNumber" && status=0 || status=1
            if [ $status -gt 0 ] 
            then
                print_log "【删除总机号码】成功" info
                assertSame 1 1
            else
                fail "【删除总机号码】失败"   
            fi 
        else
            print_log "【删除总机号码】成功" info
            assertSame 1 1
        fi
    fi
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
. ../lib/shunit2