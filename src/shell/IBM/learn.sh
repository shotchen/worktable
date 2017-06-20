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
# echo -n "9a7d485124d3cd788fb1c0ecb1103321" | openssl md5 -binary | od -tx1 -w1 | awk 'NF<2{next}{printf("%s",$2)}'
# echo -n "1234567"|openssl aes-128-ecb -K 226a89e66d0dcc79c9673150fa176001 | od -tx1 
# echo -n "1234567"|openssl aes-128-ecb -K 226a89e66d0dcc79c9673150fa176001 | od -tx1 -w1 | awk 'NF<2{next}{printf("%s",$2)}' 
# 196d7e3754c5814d4c868c38e951f588
# 196D7E3754C5814D4C868C38E951F588
# 196D7E3754C5814D4C868C38E951F588
# echo -n lun01 |openssl aes-128-ecb -K 30313233343536373839 |od -tx1
# echo -n "1234567"|openssl aes-128-ecb -K 226a89e66d0dcc79c9673150fa176001 | od -tx1 -w1 | awk 'NF<2{next}{printf("%s",$2)}'
# echo -n "196D7E3754C5814D4C868C38E951F588" | openssl aes-128-ecb -K 226a89e66d0dcc79c9673150fa176001 -d
# echo -e -n "\x19\x6D\x7E\x37\x54\xC5\x81\x4D\x4C\x86\x8C\x38\xE9\x51\xF5\x88" |openssl aes-128-ecb -K 226a89e66d0dcc79c9673150fa176001 -d
# echo -n "1234567"|openssl aes-128-ecb -K 226a89e66d0dcc79c9673150fa176001 | openssl aes-128-ecb -K 226a89e66d0dcc79c9673150fa176001 -d
#
######################################

# 
# 226A89E66D0DCC79C9673150FA176001
# 226a89e66d0dcc79c9673150fa176001
# 例如：UPPERCASE=$(echo $VARIABLE | tr '[a-z]' '[A-Z]')   (把VARIABLE的小写转换成大写)
#       LOWERCASE=$(echo $VARIABLE | tr '[A-Z]' '[a-z]')   (把VARIABLE的大写转换成小写)
######################################

# 判断命令是否存在
# $ command -v foo >/dev/null 2>&1 || { echo >&2 "I require foo but it's not installed.  Aborting."; exit 1; }
# $ type foo >/dev/null 2>&1 || { echo >&2 "I require foo but it's not installed.  Aborting."; exit 1; }
# $ hash foo 2>/dev/null || { echo >&2 "I require foo but it's not installed.  Aborting."; exit 1; }
######################################

#
# cmd > file 
# 把cmd命令的输出重定向到文件file中。如果file已经存在，则清空原有文件，使用bash的noclobber选项可以防止复盖原有文件。 
# cmd >> file 
# 把cmd命令的输出重定向到文件file中，如果file已经存在，则把信息加在原有文件後面。 
#####################################


#
# expr 9 + 7

#
# apt-get install bc
# echo "ibase=16;obase=2;ABC"|bc
# echo "ibase=16;obase=2;196D7E3754C5814D4C868C38E951F588"|bc
# echo "ibase=16;196D7E3754C5814D4C868C38E951F588"|bc
# echo 196D7E3754C5814D4C868C38E951F588 | sed 's/\(..\)/\\\\x\1/g' | xargs echo -e -n | openssl aes-128-ecb -K 226a89e66d0dcc79c9673150fa176001 -d