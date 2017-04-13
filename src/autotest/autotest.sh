#!/bin/bash
##############################
#    自动测试脚本            #
#    author  cxl             #
##############################
source input.sh
source output.sh
source emic_system.sh
source mysql.sh

function usage(){
   emic_echo_info "请输入测试文件路径,例如./autotest.sh /tmp/bsstest.json"
}

tmpfilename="tmpfile"
tmpfileidx=1

if [ $# -lt 1 ] ; then
   usage
   exit 1
fi
if [ ! -f "$1" ] ; then
   emic_echo_fail "$1文件不存在"
   exit 2
fi

emic_echo_info "读取测试数据"
test_name=`cat $1|jq '.test_name' ` && (emic_echo_success "读取成功") || (emic_echo_fail "读取失败"; exit 6;)
echo "name is $test_name"
exit 5;
if [ -z $test_name ] ; then
fi 
#cmd=`cat $1 | jq '.testdata[0]|length'`
#cmd1="php /var/pbx/mt/CliForMt/cli.php Test getZipedStr $1"
#result=$(eval $cmd1)
#echo $result
#echo $cmd
#bssRequest "-H 'Content-type:application/json; charset=UTF-8' -H 'Accept:application/json'" "-d 'ddd=df&sd=23'" ""
#bssRequest "-H 'Content-type:application/json; charset=UTF-8' -H 'Accept:application/json'" "-d 'ddd=df&sd=23'" ""
#bssRequest "" ""
#curlRequest "" "-d 'Operate=createswitchboard&Number=01081774908&MaxMember=30&EpName=我们是害虫'" "" $BSS_REQUEST_URL
#eval_cmd "curl -d 'Operate=createswitchboard&Number=01081774908&MaxMember=30&EpName=我们是害虫' http://127.0.0.1:1046/Api/Bss/bssHttp"
tmpfile="$tmpfilename$tmpfileidx.txt"
#let "tmpfileidx+=1"
#echo $tmpfileidx
#mysqlCmd="mysql -u$MYSQL_USER -p\"$MYSQL_PWD\" --local-infile=1 -e \"select count(*) from talk.talk_enterprise into outfile '/tmp/$tmpfile'; \""
#prepareCmd=`cat $1 | jq '.prepare_cmd[0].command'`
#echo $mysqlCmd
#echo $prepareCmd
#eval "pp=$prepareCmd"
#echo $pp
#eval_cmd $pp
#echo $tmpfilename
emic_echo_info "测试结果"
