#! /bin/bash

######################################
# 
# 脚本名称: shunit2_usage.sh
#
# 目的:
#    1、shunit2使用示例
# 
# 注意事项：
#    
# 作者: chenxuelin@emicnet.com
# 
######################################

oneTimeSetUp(){
    echo "version is ${SHUNIT_VERSION}"
    echo "oneTimeSetUp函数出现在所有测试的开始，一次测试只出现一次"
    echo ""
}
setUp(){
    echo "setUp函数，每个测试方法前执行"
    echo "lineno:${LINENO:-}"
    echo ""
}

testEquals(){
    echo "测试相等 assertEquals(assertSame) '不相等出现的说明文字' 1 1"
    assertEquals 'equals不相等出现的说明文字' 1 1
    #assertSame 'same不相等出现的说明文字' '' ''
    #assertSame 'same不相等出现的说明文字' 'X' ''
    echo ""
}

testNotEquals(){
    echo "测试相等 assertNotEquals(assertNotSame) '相等出现的说明文字' 1 1"
    assertNotEquals 'equals相等出现的说明文字' 1 1
    assertNotSame 'same相等出现的说明文字' 1 2
    echo ""
}

testNull(){
    echo "测试 assertNull '不为NULL时出现' 1 "
    assertNull '不为NULL时出现' 1 
    assertNull '空字符串出现' '' 
    echo ""
}

testTrue(){
    echo "测试 assertTrue '不为true时显示' '[ 34 -gt 23 ]'"
    assertTrue '不为true时显示' "[ 34 -gt 23 ]"
    assertFalse '为true时显示' "[ 34 -gt 23 ]"
    echo ""
}

testFail(){
    echo '测试fail "fail message"'
    assertTrue '不为true时显示' "[ 34 -gt 23 ]"
    fail "fail message"
    failNotEquals "this is fail message" "no" "yes"
    echo ""
}

testLineNo(){
    assertEquals --lineno "${LINENO:-}" 'not equal' 1 3
    ${_ASSERT_EQUALS_} '"not equal"' 1 2
}

tearDown(){
    echo "tearDown函数，每个测试方法后执行"
    echo ""
}
oneTimeTearDown(){
    echo "oneTimeTearDown函数出现在所有测试结束后，一次测试只出现一次"
    echo ""
}

# 加载shunit2开始测试
. ../lib/shunit2