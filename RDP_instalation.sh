#!/bin/bash
red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`

functiondownload(){
	echo -e "[xrdp]
name=xrdp
baseurl=http://li.nux.ro/download/nux/dextop/el7/x86_64/
enabled=1
gpgcheck=0" > /etc/yum.repos.d/xrdp.repo
	dhclient
	rpm -Uvh http://li.nux.ro/download/nux/dextop/el7/x86_64/nux-dextop-release-0-1.el7.nux.noarch.rpm
	rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm >/dev/null
	yum -y install xrdp tigervnc-server
	systemctl enable xrdp.service 
	firewall-cmd --permanent --zone=public --add-port=3389/tcp
	firewall-cmd --reload
	chcon --type=bin_t /usr/sbin/xrdp
	chcon --type=bin_t /usr/sbin/xrdp-sesman
	systemctl start xrdp.service

} 

echo "${green}###############################################################${reset}"
echo "${green}################ This is RDP instalation ######################${reset}"
echo "${green}###############################################################${reset}"
read -p "${green} Do you wanto continue this prosess ${green}yes${reset} or ${red}no${reset}? :" answer
if [ $answer == "yes" ]
then
	yum update -y
	functiondownload
	
	echo "${green} RPD Remote Controle Desktop installed ${reset}"
else
	echo "${red} Bye :)) ${reset}"
fi
