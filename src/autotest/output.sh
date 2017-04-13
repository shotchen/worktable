##############################
#    输出相关shell函数       #
#    author  cxl             #
##############################

RED_COLOR='\E[1;31m'  #红
GREEN_COLOR='\E[1;32m' #绿
YELOW_COLOR='\E[1;33m' #黄
BLUE_COLOR='\E[1;34m'  #蓝
PINK_COLOR='\E[1;35m'      #粉红
RES='\E[0m'

OK_MSG="${GREEN_COLOR}OK${RES}"
FAIL_MSG="${RED_COLOR}FAIL${RES}"
RESULT_FILE="/tmp/result.txt"


###### 显示成功信息 ######
function emic_echo_success(){
   echo -e "******  [${GREEN_COLOR}$1${RES}] ******"
}
###### 显示失败信息 ######
function emic_echo_fail(){
   echo -e "******  [${RED_COLOR}$1${RES}] ******"
}
###### 显示提示信息 ######
function emic_echo_info(){
   echo -e "******  [${BLUE_COLOR}$1${RES}] ******"
}
###### 显示警告信息 ######
function emic_echo_warn(){
   echo -e "******  [${PINK_COLOR}$1${RES}] ******"
}
###### 执行命令行并返回结果 ######
function eval_cmd(){
   if [ -z "$1" ] ; then
	emic_echo_fail "未输入需执行的命令"
	return false
   fi
   #echo "--$1"
   eval "$1"  && status=0 || status=1 
   if [ $status -gt 0 ] ; then
	echo -e "****** $1 [$FAIL_MSG] ******"
   else
	echo -e "****** $1 [$OK_MSG] ******"
   fi
   return $status
}
###### 显示信息 ######
function emic_echo_msg(){   
   msg="alert info"
   eType="uknown"  
   if [ -n "$1" ] ; then 
	msg="$1" 
   fi
   if [ -n "$2" ] ; then 
        eType="$2" 
   fi
   case $eType in 
      info)
         echo -e "[${BLUE_COLOR}$msg${RES}]"
      ;;
      warn)
         echo -e "[${PINK_COLOR}$msg${RES}]"
      ;;
      success)
         echo -e "[${GREEN_COLOR}$msg${RES}]"
      ;;
      fail)
         echo -e "[${RED_COLOR}$msg${RES}]"
      ;;
      * )
         echo -e "[$msg]"
   esac
}