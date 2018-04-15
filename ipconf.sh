#!/bin/bash
green=`tput setaf 2`
red=`tput setaf 1`
reset=`tput sgr0`
cp /etc/sysconfig/network-scripts/ifcfg-eth0 /etc/sysconfig/network-scripts/ifcfg-eth0.back
FILE="/etc/sysconfig/network-scripts/ifcfg-eth0"

functionback(){
sed 's/ONBOOT=no/ONBOOT=yes/g' -i $FILE
sed 's/BOOTPROTO=static/BOOTPROTO=dhcp/g' -i $FILE
echo "$(grep -v "IP" $FILE)" > $FILE
echo "$(grep -v "GATE" $FILE)" > $FILE
echo "$(grep -v "DNS" $FILE)" > $FILE
echo "$(grep -v "NETMASK" $FILE)" > $FILE
service network restart
}

functiondhcp(){
sed 's/ONBOOT=no/ONBOOT=yes/g' -i $FILE
sed 's/BOOTPROTO=static/BOOTPROTO=dhcp/g' -i $FILE 
echo "$(grep -v "IP" $FILE)" > $FILE 
echo "$(grep -v "GATE" $FILE)" > $FILE 
echo "$(grep -v "DNS" $FILE)" > $FILE 
echo "$(grep -v "NETMASK" $FILE)" > $FILE 
echo ""
echo "DHCP installed"
echo ""
read -p "do you want to restart network yes/no? : " ans3
if [ $ans3 == "yes" ] || [ $ans3 == "Yes" ]
then
	service network restart
else
	exit 1
fi
}


functionstatic(){
sed 's/ONBOOT=no/ONBOOT=yes/g' -i $FILE
sed 's/BOOTPROTO=dhcp/BOOTPROTO=static/g' -i $FILE
echo "$(grep -v "IP" $FILE)" > $FILE 
echo "$(grep -v "GATE" $FILE)" > $FILE 
echo "$(grep -v "DNS" $FILE)" > $FILE 
echo "$(grep -v "NETMASK" $FILE)" > $FILE 
read -p "Enter the ip :" USERIP
read -p "Enter the gateway :" USERGATEWAY
echo "IPADDR=$USERIP" >> $FILE
echo "NETMASK=255.255.255.0" >> $FILE
echo "GATEWAY=$USERGATEWAY" >> $FILE
echo "DNS1=8.8.8.8" >> $FILE
sleep 2.2
cat $FILE
}
functionrestart(){
read -p "do you want to restart network? :" ans2
if [ $ans2 == "yes" ]
then	
	echo "Start network restart"
	service network restart
		
else 
	echo "byes"
 
fi
}
functioncheck(){
echo "${green}######################################################"
echo "# You install static IP"
ping -c 4 8.8.8.8
echo "######################################################"${reset}
}

echo ${green}"############################################"
echo "####### Welcome Farkhod's script ###########"
echo "##############################################"${reset}
echo ""
echo "1. CetnOS 6"
echo "2. CetnOS 7"
echo ""
read -p "Which of these Os is your? " os
if [ $os -eq "1" ]
then	
	echo ""
	echo ${red}"##########################################"
	echo "1. set ipstatic"
	echo "2. set dhcp"
	echo "3. quit"
	read -p "Please choose the oprions :"${reset} ans1
	if [ $ans1 -eq "1" ]
	then
		echo ""
		functionstatic
		functionrestart
		functioncheck		
	fi	
	if [ $ans1 -eq "2" ]
	then
		echo "2"
		functiondhcp
	fi	
	if [ $ans1 -eq "3" ]
	then
		exit 1
	fi	
fi
	
if [ $os -eq "2" ]
then 
	echo "Centos 7"
fi
