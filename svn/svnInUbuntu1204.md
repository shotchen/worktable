# ubuntu12.04安装svn1.8

* sudo sh -c 'echo "deb http://opensource.wandisco.com/ubuntu precise svn18" >> /etc/apt/sources.list.d/subversion18.list'
* sudo wget -q http://opensource.wandisco.com/wandisco-debian.gpg -O- | sudo apt-key add -
* sudo apt-get update
* sudo apt-cache show subversion | grep '^Version:'
* sudo apt-get install subversion

# 使用
svn info svn://192.168.1.66/namtso/branch/web_code/emic_phone/oauth_server 
svn log --username chenxl --password xuelin svn://192.168.1.66/namtso/branch/web_code/emic_phone/oauth_server  -l 10

svn log --incremental  --username chenxl --password  xuelin svn://192.168.1.66/namtso/branch/web_code/emic_phone/oauth_server  -l 10