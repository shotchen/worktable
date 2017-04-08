# install ubuntu1404
* vboxmanage createvm --name "ubuntu1404-base" --ostype "Ubuntu_64" --basefolder "/home/cxl/virtualbox/vm/" --register 
* vboxmanage createhd --filename /home/cxl/virtualbox/vm/ubuntu1404-base/ubuntu1404-base --size 30000
* vboxmanage storagectl "ubuntu1404-base" --add ide --name "IDE Controller" --bootable on
* vboxmanage storageattach "ubuntu1404-base" --storagectl "IDE Controller" --port 0 --device 0 --type hdd --medium "/home/cxl/virtualbox/vm/ubuntu1404-base/ubuntu1404-base.vdi"
* vboxmanage storageattach "ubuntu1404-base" --storagectl "IDE Controller" --port 1 --device 0 --type dvddrive --medium "/home/cxl/virtualbox/iso/ubuntu-14.04.5-server-amd64.iso" 
* vboxmanage modifyvm "ubuntu1404-base" --memory 512 --vram 8 --nic1 bridged --bridgeadapter1 eth0 --vrde on --vrdeport 4999
* vboxmanage startvm ubuntu1404-base --type headless

# config system
## change root password
* sudo su root
* passwd

## network config
* vi /etc/network/interfaces 
    auto eth0
    iface eth0 inet static
    address 10.0.0.23
    netmask 255.255.255.0
    gateway 10.0.0.254
    dns-nameservers 8.8.8.8 202.106.0.20
* ifdown eth0
* ifup eth0
* ifdown --exclude=lo -a && sudo ifup --exclude=lo -a

## install samba
* apt-get install samba
* smbpasswd -a cxl
* vi /etc/samba/smb.conf
    [global]
    security = user
    [homes]
    browseable = yes
    public = no
    writeable = yes
* /etc/init.d/smbd restart

## install ssh
* apt-get install openssh-server
* vi /etc/ssh/sshd_config 
     #PermitRootLogin without-password
     PermitRootLogin yes
* service ssh restart

# clonevm 
* vboxmanage controlvm "ubuntu1404-base" acpipowerbutton
* vboxmanage clonevm "ubuntu1404-base" --name "36-30g1404" --register --basefolder "/home/cxl/virtualbox/vm/"
* vboxmanage clonevm "ubuntu1404-base" --name "37-30g1404" --register --basefolder "/home/cxl/virtualbox/vm/"
* vboxmanage clonevm "ubuntu1404-base" --name "38-30g1404" --register --basefolder "/home/cxl/virtualbox/vm/"
* vboxmanage modifyvm ubuntu1404-base --vrde off

# startvm and config vm
* vboxmanage startvm 36-30g1404 --type headless
* vboxmanage startvm 37-30g1404 --type headless
* vboxmanage startvm 38-30g1404 --type headless
* network config like base vm
* vboxmanage modifyvm 36-30g1404 --vrde off
* vboxmanage modifyvm 37-30g1404 --vrde off
* vboxmanage modifyvm 38-30g1404 --vrde off
