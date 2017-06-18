= 拓扑图 =
 安装环境 ubuntu 16.04
 [[File:Example21.jpg]]

= 安装nginx =
  apt install nginx
* 查看版本
  root@1604developer:~# nginx -v
  nginx version: nginx/1.10.0 (Ubuntu)
* 配置目录
  /etc/nginx

= 安装apache =
  apt install apache2
* 查看版本
  apache2 -v
  Server version: Apache/2.4.18 (Ubuntu)
  Server built:   2017-05-05T16:32:00
* 配置目录
  /etc/apache2

= 安装php7 =
  apt install php
* 查看版本
 root@1604developer:~# php -v
 PHP 7.0.18-0ubuntu0.16.04.1 (cli) ( NTS )
 Copyright (c) 1997-2017 The PHP Group
 Zend Engine v3.0.0, Copyright (c) 1998-2017 Zend Technologies
 with Zend OPcache v7.0.18-0ubuntu0.16.04.1, Copyright (c) 1999-2017, by Zend Technologies
* 配置目录
 /etc/apache2

= 安装mysql =
 apt install mysql-server
 设置root密码C1oudP8x&2017
= 安装redis =
 [http://10.0.0.64/wiki/index.php/Redis服务器研究 Redis服务器研究]
 redis暂用10.0.0.37 数据库1

= 安装依赖 =
 apt install php-curl
 apt install php-mbstring
 apt-get install libapache2-mod-php7.0
 apt install php-gd
 apt install php7.0-mysql
 apt install php-redis

= 安装thinkphp5.09 =
 拷贝/home/cxl/thinkphp_5.0.9_full

= 版本管理安装 =
 apt install subversion
 apt install git

= 相关配置与测试 =
== thinkphp5 ==
* 发布到git服务器
  http://10.0.0.28/websrc/tp5-project.git
* clone到42、43、44、45服务器
  cd /home/cxl
  git clone http://10.0.0.28/websrc/tp5-project.git
* 软链接到/var/www目录下
  ln -s /home/cxl/tp5-project /var/www/tp5

== apache ==
* 配置apache监听1065端口
** /etc/apache2/ports.conf 
   Listen 1065
** /etc/apache2/1065.conf
   ServerAdmin webmaster@localhost
   DocumentRoot /var/www/tp5/public
   <Directory /var/www/tp5/public/>
       Options Indexes FollowSymLinks
       AllowOverride All
       Require all granted
   </Directory>

== 测试thinkphp标准api返回 ==
* 在controller下新建类Test.php
  namespace app\index\controller;
  class Test{
    public function index(){
         $data = ['name'=>'thinkphp','url'=>'thinkphp.cn'];      
         return ['data'=>$data,'code'=>1,'message'=>'操作完成'];  
    }
  }
* 修改config.php配置
  // 默认输出类型
  'default_return_type'    => 'json',
* 访问[http://10.0.0.42:1065/index/test/index 测试页面]
  {"data":{"name":"thinkphp","url":"thinkphp.cn"},"code":1,"message":"操作完成"}

== 配置mysql主从服务器 ==
# mysql 主服务器（写入) 10.0.0.45  
* 配置vi /etc/mysql/mysql.conf.d/mysqld.cnf 
  #bind-address           = 127.0.0.1 # 允许远程访问
  server-id               = 45
  log-bin                 = mysql-bin
* 添加同步数据用户
  mysql> CREATE USER 'repl'@'10.0.0.%' IDENTIFIED BY 'slavepass';
  mysql> GRANT REPLICATION SLAVE ON *.* TO 'repl'@'10.0.0.%';
* 查看主服务器状态
  mysql> show master status;
  +------------------+----------+--------------+------------------+-------------------+
  | File             | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |
  +------------------+----------+--------------+------------------+-------------------+
  | mysql-bin.000001 |     1224 |              |                  |                   |
  +------------------+----------+--------------+------------------+-------------------+
  1 row in set (0.00 sec)
   
# mysql 从服务器（读取) 10.0.0.44、10.0.0.43、10.0.0.42（应用不读取、只做备份，可以临时切换为主服务器）
* 配置 vi /etc/mysql/mysql.conf.d/mysqld.cnf
  #bind-address           = 127.0.0.1 # 允许远程访问
  server-id               = 42|43|44
* 配置连接主服务器参数
  mysql> CHANGE MASTER TO MASTER_HOST='10.0.0.45',MASTER_USER='repl',MASTER_PASSWORD='slavepass',MASTER_LOG_FILE='mysql-bin.000001',MASTER_LOG_POS=1224;
* 启动从服务器
  mysql> START SLAVE;
* 主从服务器uuid相同
  select uuid()
  vi /var/lib/mysql/auto.cnf
  修改所有从服务器uuid
* 查看从服务器状态
  mysql> show slave status\G
  *************************** 1. row ***************************
               Slave_IO_State: Waiting for master to send event
                  Master_Host: 10.0.0.45
                  Master_User: repl
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: mysql-bin.000001
          Read_Master_Log_Pos: 1224
               Relay_Log_File: 1604developer-relay-bin.000003
                Relay_Log_Pos: 320
        Relay_Master_Log_File: mysql-bin.000001
             Slave_IO_Running: Yes
            Slave_SQL_Running: Yes
              Replicate_Do_DB: 
          Replicate_Ignore_DB: 
           Replicate_Do_Table: 
       Replicate_Ignore_Table: 
      Replicate_Wild_Do_Table: 
  Replicate_Wild_Ignore_Table: 
                   Last_Errno: 0
                   Last_Error: 
                 Skip_Counter: 0
          Exec_Master_Log_Pos: 1224
              Relay_Log_Space: 535
              Until_Condition: None
               Until_Log_File: 
                Until_Log_Pos: 0
           Master_SSL_Allowed: No
           Master_SSL_CA_File: 
           Master_SSL_CA_Path: 
              Master_SSL_Cert: 
            Master_SSL_Cipher: 
               Master_SSL_Key: 
        Seconds_Behind_Master: 0
  Master_SSL_Verify_Server_Cert: No
                Last_IO_Errno: 0
                Last_IO_Error: 
               Last_SQL_Errno: 0
               Last_SQL_Error: 
  Replicate_Ignore_Server_Ids: 
             Master_Server_Id: 45
                  Master_UUID: 5902f28d-45cb-11e7-af27-080027c869aa
             Master_Info_File: /var/lib/mysql/master.info
                    SQL_Delay: 0
          SQL_Remaining_Delay: NULL
      Slave_SQL_Running_State: Slave has read all relay log; waiting for more updates
           Master_Retry_Count: 86400
                  Master_Bind: 
      Last_IO_Error_Timestamp: 
     Last_SQL_Error_Timestamp: 
               Master_SSL_Crl: 
           Master_SSL_Crlpath: 
           Retrieved_Gtid_Set: 
            Executed_Gtid_Set: 
                Auto_Position: 0
         Replicate_Rewrite_DB: 
                 Channel_Name: 
           Master_TLS_Version: 
  1 row in set (0.00 sec)
# 测试主从服务器
* 在主服务器创建数据库spi
  drop database if exists spi;
  CREATE DATABASE IF NOT EXISTS `spi` default character set utf8 collate utf8_unicode_ci;
* 在从服务器查看数据库spi是否创建成功
  mysql> show databases like 'spi%';
  +-----------------+
  | Database (spi%) |
  +-----------------+
  | spi             |
  +-----------------+
  1 row in set (0.00 sec)

== 测试thinkphp连接数据库 ==
* 创建mysql用户
   mysql> CREATE USER 'spiuser'@'10.0.0.%' IDENTIFIED BY '123456';
   mysql> GRANT ALL ON spi.* TO 'spiuser'@'10.0.0.%';
   mysql> flush privileges;
   mysql>ALTER USER 'root'@'localhost' IDENTIFIED BY 'C1oudP8x&2017';
* 修改thinkphp数据库配置文件
  application/database
  http://10.0.0.42:1065/index/test/usedb
  use think\Db;
  public function usedb(){
    	echo "usedb test";
    	$sql = "CREATE TABLE IF NOT EXISTS `test` (`id` int(11) NOT NULL AUTO_INCREMENT,`name` varchar(255) NOT NULL,PRIMARY KEY (`id`)) ENGINE=innodb;";
    	Db::execute($sql);
 }

== nginx配置 ==
# 停止43、44、45上nginx
  ps -aux|grep nginx
  kill xxxxx #nginx主进程
  update-rc.d -f nginx remove
  不管用
  apt remove nginx
  apt autoremove 
  ps -ef|grep nginx
# 参考谷卫文档配置
* [http://10.0.0.64/wiki/index.php/Nginx负载分担 Nginx负载分担]
** 拷贝证书
   root@1604developer:/etc/nginx/crt# ll /etc/nginx/crt
   total 20
   drwxr-xr-x 2 root root 4096 Jun  1 10:00 ./
   drwxr-xr-x 7 root root 4096 Jun  1 10:00 ../
   -rwxr--r-- 1 root root 5528 Jun  1 10:00 _.emic.com.cn_bundle.crt*
   -rwxr--r-- 1 root root 1704 Jun  1 10:00 _.emic.com.cn.key*
** 配置https访问
  /etc/nginx/sites-enable/443-ssl
# 测试负载分担
* 部署tp5
* 测试访问

# 测试session共享
* 配置redis
* 测试访问打印session

== 开发模式 ==
  参考https://github.com/honraytech/VueThink/  搭建前后端分离架构
* 前端开发
  1、 安装nodejs
      curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
      apt install nodejs   
      node --version
      v6.11.0
  2、 下载版本git clone https://github.com/honraytech/VueThink.git
  3、 git clone http://10.0.0.28/websrc/vuefront.git
      https://vuefe.cn/v2/guide/installation.html
      npm install --global vue-cli
      vue init webpack vuefront
      cd vuefront
      npm install
      npm run dev

* 后端开发
  写一个测试接口
  http://10.0.0.42:1065/index/index/login
* 前后端联调
  vue增加一个路由login
