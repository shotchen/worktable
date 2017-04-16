#!/usr/bash
#
# 学习bash的测试shell
##############################


#
#    $# 位置参数的数量。
#　　$* 所有位置参数的内容。
#　　$? 命令执行后返回的状态。
#　　$$ 当前进程的进程号。
#　　$! 后台运行的最后一个进程号。
#　　$0 当前执行的进程名。
##############################

#
# shift 删除一个参数
# 
##############################

#
# getopts
# $OPTIND 当前序号
# $OPTARG 参数值
# 
##############################

echo 初始 OPTIND: $OPTIND

while getopts "a:b:c" arg #选项后面的冒号表示该选项需要参数
do
    case $arg in
        a)
			echo "a's arg:$OPTARG" #参数存在$OPTARG中
			;;
        b)
			echo "b's arg:$OPTARG"
			;;
        c)
			echo "c's arg:$OPTARG"
			;;
        ?)  #当有不认识的选项的时候arg为?
			echo "unkonw argument"
			exit 1
		;;
    esac
done

echo 处理完参数后的 OPTIND：$OPTIND
echo 移除已处理参数个数：$((OPTIND-1))
shift $((OPTIND-1))
echo 参数索引位置：$OPTIND
echo 准备处理余下的参数：
echo "Other Params: $@"


#
# echo -n '123456' | openssl md5
# echo -n '123456' | md5sum
# select md5("123456");
# php -r 'echo md5("123");'
#
############################


#
# echo -n '9a7d485124d3cd788fb1c0ecb1103321' | openssl md5 -binary
# echo -n "1234567" | openssl aes-128-ecb -k \"j1P | od -tx1
# echo -n "9a7d485124d3cd788fb1c0ecb1103321" | openssl md5 -binary | od -tx1   226a89e66d0dcc79c9673150fa176001
# echo -n "1234567"|openssl aes-128-ecb -K 226a89e66d0dcc79c9673150fa176001 | od -tx1 
# echo -n lun01 |openssl aes-128-ecb -K 30313233343536373839 |od -tx1
#
######################################

# 
# 226A89E66D0DCC79C9673150FA176001
# 226a89e66d0dcc79c9673150fa176001
# 例如：UPPERCASE=$(echo $VARIABLE | tr '[a-z]' '[A-Z]')   (把VARIABLE的小写转换成大写)
#       LOWERCASE=$(echo $VARIABLE | tr '[A-Z]' '[a-z]')   (把VARIABLE的大写转换成小写)
######################################