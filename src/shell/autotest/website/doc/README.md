######################################
# 
# 脚本名称: README.md
#
# 目的:
#    1、仓库地址
#    2、介绍目录结构
#    3、声明依赖
#    4、使用方法
#
# 注意事项：
#    
# 作者: chenxuelin@emicnet.com
# 
######################################

# 仓库路径
		
	git clone http://10.0.0.28/webPublic/autotest.git

# 目录结构

- bin
	命令行工具
- bucket
	测试方法
- - template
		测试模板目录
- conf
	配置文件
- doc
	相关文档
- lib 
	第三方库
- src
	源代码
- website
	web站点


# 依赖

* 基于shunit2开发
	git clone https://github.com/kward/shunit2.git ，项目文件已包含文件，不需要单独下载
* 依赖于shell下json解析器jq
	apt-get install  jq -y
* 依赖于shell下xml解析器xmlstarlet
	apt-get install  xmlstarlet -y

# 开始使用
	已bucket/test_bss_chongqing.sh为例
* 在测试服务器上运行用例需依赖类库
	在运维上运行bin/depend_maintenance.sh
* 在目标机器上允许用例需依赖类库
	在测试机器上运行 bin/depend_test.sh
* 修改emic_conf配置测试环境常用变量
	如果use_db=true设置为true，必须保证测试机器能访问运维或企业mysql数据库
	配置方法：在mysql运行，grant all on *.* to root@10.0.0.40 identified by 'C1oudP8x&2017' with grant option;测试是否远程访问数据库，mysql -uroot -p'C1oudP8x&2017' -h 10.0.0.23
	如果use_db=true设置为true,请手动修改server_province
* 运行测试用例
	bucket/test_bss_chongqing.sh
* 查看打印报告
* 查看bucket/emic.log
	

	