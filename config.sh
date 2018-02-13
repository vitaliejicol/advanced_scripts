#!/bin/bash

oscheck()
{
	for ((g=0; g<=10; g++))
	do
		d=$( cat /etc/redhat-release |  awk '{ print $'$g' }' )
		dd=$( cat /etc/redhat-release |  awk '{ print $'$g'$'$(($g+1))' }' )
		if [[ $d =~ ^[cC][eE][nN][tT][oO][sS]$ ]]
		then
			os="CentOS"
		elif [[ $dd =~ ^[rR][eE][dD][hH][aA][tT]$ ]]
		then
			os="RedHat"
		elif [[ $d =~ ^[6]\.[0-9].* ]]
		then
			ver=6
			for ((v=0; v<10; v++))
			do
				if [ -z "$( ethtool eth$v 2>&1 | grep "No such device" )" ]
					then
				        dev[$v]="eth$v"
				else
					break
				fi
			done
		elif [[ $d =~ ^[7]\.[0-9].* ]]
		then
			dev=($( nmcli d | awk 'NR>2{ print l} {l=$1}' ))
			ver=7
		fi
	done
	echo $os $ver
}

oscheck

ipcheck()
{
	if [[ $1 =~ ^[1-9][0-9]{0,2}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]
	then
		ipcheckout=1
	else
		ipcheckout=0
	fi
}

netmaskcheck()
{
	z=$1
	netmask=""
	for ((q=0; q<4; q++))
	do
		if [ $z -ge 8 ]
		then
			z=$(( $z - 8 ))
			netmask=$netmask"255"
		elif [ $z -eq 7 ]
		then
			z=0
			netmask=$netmask"254"
		elif [ $z -eq 6 ]
		then
			z=0
                        netmask=$netmask"252"
		elif [ $z -eq 5 ]
                then
			z=0
                        netmask=$netmask"248"
		elif [ $z -eq 4 ]
                then
			z=0
                        netmask=$netmask"240"
		elif [ $z -eq 3 ]
                then
			z=0
                        netmask=$netmask"224"
		elif [ $z -eq 2 ]
                then
			z=0
                        netmask=$netmask"192"
		elif [ $z -eq 1 ]
                then
			z=0
                        netmask=$netmask"128"
		elif [ $z -eq 0 ]
		then
			netmask=$netmask"0"
		fi
		if [ $q -lt 3 ]
		then
			netmask=$netmask"."
		fi
	done
}

i=0

for eth in ${dev[*]}
do
	echo "here"
	while true
	do
		ipcheck $( ip addr show $eth 2> /dev/null | grep 'inet [0-9]\{1,3\}' | awk '{print $2}' | sed  s/'\/[0-9]\{1,2\}$'/''/ )
		if [ $ipcheckout -lt 1 ]
		then
			if [ -n "$( ip addr show $eth 2> /dev/null | grep "link/ether" )" ]
			then
				ifup $eth
	        	        continue
			else
				break
			fi
		else
			ip[$i]=$( ip addr show $eth | grep 'inet [0-9]\{1,3\}' | awk '{print $2}' | sed  s/'\/[0-9]\{1,2\}$'/''/ )
	        	bit[$i]=$( ip addr show $eth | grep 'inet [0-9]\{1,3\}' | awk '{print $2}' | sed  s/'^.*\/'/''/ )

			echo "$eth is ${ip[$i]}"
			gw[$i]=$( echo ${ip[$i]} | sed -e s/'\.[0-9]\{1,3\}$'/'.1'/ )
			hwaddr[$i]=$( ip addr show $eth | grep "link/ether" | awk '{print $2}' )

			while true
			do
				echo $i
				echo $eth
				echo ${bit[$i]}
				echo ${ip[$i]}
				echo ${gw[$i]}
				echo ${hwaddr[$i]}

				read -p "Do you want to configure $eth? (y/n)" ans1
				if [[ $ans1 = [yY] ]]
        		        then
					echo -e "1.Static\n2.DHCP"
					read -p "Please choose:" ans2			
					if [ $ans2 -eq 1 ]
        		        	then
        			                read -p "Please enter new IP for $eth:" statip
						ipcheck $statip
						if [ $ipcheckout -gt 0 ]
	                        		then
							echo "DEVICE=$eth" > /etc/sysconfig/network-scripts/ifcfg-$eth
	       	                        	        echo "HWADDR=${hwaddr[$i]}" >> /etc/sysconfig/network-scripts/ifcfg-$eth
        	                                	echo "TYPE=Ethernet" >> /etc/sysconfig/network-scripts/ifcfg-$eth
                        	                	echo "ONBOOT=yes" >> /etc/sysconfig/network-scripts/ifcfg-$eth
       	        	                	        echo "NM_CONTROLLED=no" >> /etc/sysconfig/network-scripts/ifcfg-$eth
               	        		                echo "BOOTPROTO=none" >> /etc/sysconfig/network-scripts/ifcfg-$eth
               		                	        echo "IPADDR=$statip" >> /etc/sysconfig/network-scripts/ifcfg-$eth
							ip[$i]=$statip
							netmaskcheck ${bit[$i]}
							echo "NETMASK=$netmask" >> /etc/sysconfig/network-scripts/ifcfg-$eth
							if [ $i -eq 0 ]
							then
								echo "DNS1=${gw[$i]}30" >> /etc/sysconfig/network-scripts/ifcfg-$eth
								echo "DNS2=8.8.8.8" >> /etc/sysconfig/network-scripts/ifcfg-$eth
							fi
							break
        	                		else
                	                		echo "This is not a valid IP address"
	                	                	continue
	        	        	        fi
	        	        	elif [ $ans2 -eq 2 ]
					then
						echo "DEVICE=$eth" > /etc/sysconfig/network-scripts/ifcfg-$eth
                        	                echo "HWADDR=${hwaddr[$i]}" >> /etc/sysconfig/network-scripts/ifcfg-$eth
                                	        echo "TYPE=Ethernet" >> /etc/sysconfig/network-scripts/ifcfg-$eth
                                        	echo "ONBOOT=yes" >> /etc/sysconfig/network-scripts/ifcfg-$eth
	                                        echo "NM_CONTROLLED=no" >> /etc/sysconfig/network-scripts/ifcfg-$eth
        	                                echo "BOOTPROTO=dhcp" >> /etc/sysconfig/network-scripts/ifcfg-$eth
						break
					else
        		        	        continue
		        	        fi
				else
					break
				fi
			done
		fi
		i=$(( $i + 1 ))
		break
	done
done

i=0

while true
do
	dgw=$(  grep '[gG][aA][tT][eE][wW][aA][yY]' /etc/sysconfig/network | sed  s/'[gG][aA][tT][eE][wW][aA][yY]='/''/ )
	ipcheck $dgw
	if [ $ipcheckout -gt 0 ]
	then
		echo "Current default gateway: $dgw"

		read -p "Do you want to change default gateway? (y/n)" ans
	
		if [[ $ans = [yY] ]]
		then
			read -p "Please enter gateway address: " dgw
			ipcheck $dgw
			if [ $ipcheckout -gt 0 ]
			then
				sed -i s/'=[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}$'/"=$dgw"/ /etc/sysconfig/network
				break
			else
				echo "This is not a valid gateway address"
				continue
			fi
		else
			break
		fi
	else
		if [ -z $dgw ]
		then
			echo "GATEWAY=${gw[0]}" >> /etc/sysconfig/network
			continue
		else
			sed -i -e  s/'.*[gG][aA][tT][eE][wW][aA][yY].*'/"GATEWAY=${gw[0]}"/ /etc/sysconfig/network
			continue
		fi
	fi

	i=$(( $i + 1 ))
done

echo "Your hostname is: $( grep '[hH][oO][sS][tT][nN][aA][mM][eE]' /etc/sysconfig/network  | sed s/'[hH][oO][sS][tT][nN][aA][mM][eE]='/''/ )"
read -p "Do you want to change hostname? (y/n)" ans3
if [[ $ans3 =~ [yY] ]]
then
	read -p "Enter new hostname:" hostname
        sed -i s/'^[hH][oO][sS][tT][nN][aA][mM][eE].*$'/"HOSTNAME=$hostname"/  /etc/sysconfig/network
fi


read -p "Do you want to reboot the server? (y/n)" ans4
if [[ $ans4 =~ [yY] ]]
then
        reboot > /dev/null 2>&1
fi







