# sh免密码登录 

 ssh-keygen -t rsa -P ''
 scp /root/.ssh/id_rsa.pub  root@10.0.0.23:/root/.ssh/authorized_keys
 ssh -i /root/.ssh/id_rsa root@10.0.0.23
 ssh 10.0.0.23

