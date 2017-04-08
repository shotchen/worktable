# install ubuntu1404
* vboxmanage createvm --name "ubuntu1404-base" --ostype "Ubuntu_64" --basefolder "/home/cxl/virtualbox/vm/" --register 
* vboxmanage createhd --filename /home/cxl/virtualbox/vm/ubuntu1404-base/ubuntu1404-base --size 30000
* vboxmanage storagectl "ubuntu1404-base" --add ide --name "IDE Controller" --bootable on
* vboxmanage storageattach "ubuntu1404-base" --storagectl "IDE Controller" --port 0 --device 0 --type hdd --medium "/home/cxl/virtualbox/vm/ubuntu1404-base/ubuntu1404-base.vdi"
* vboxmanage storageattach "ubuntu1404-base" --storagectl "IDE Controller" --port 1 --device 0 --type dvddrive --medium "/home/cxl/virtualbox/iso/ubuntu-14.04.5-server-amd64.iso" 
* vboxmanage modifyvm "ubuntu1404-base" --memory 512 --vram 8 --nic1 bridged --bridgeadapter1 eth0 --vrde on --vrdeport 4999
* vboxmanage startvm ubuntu1404-base --type headless

# config system
* sudo su root
