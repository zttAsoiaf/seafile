#!/bin/bash
################ install seafile ##################
#Author:xiaoz.me
#Update:2018-03-09
#######################   END   #######################

#firewall port change
function chk_firewall() {
	if [ -e "/etc/sysconfig/iptables" ]
	then
		iptables -I INPUT -p tcp --dport 8000 -j ACCEPT
		iptables -I INPUT -p tcp --dport 8082 -j ACCEPT
		service iptables save
		service iptables restart
	else
		firewall-cmd --zone=public --add-port=8000/tcp --permanent
		firewall-cmd --zone=public --add-port=8082/tcp --permanent
		firewall-cmd --reload
	fi
}

function install_sea() {
	cd /home/MyCloud
	wget https://obs-nina.obs.cn-south-1.myhuaweicloud.com:443/seafile-server_6.2.3_x86-64.tar.gz
	tar -zxvf seafile-server_6.2.3_x86-64.tar.gz
	mkdir installed
	mv seafile-server*.tar.gz ./installed
	mv seafile-server-6* seafile-server
	yum -y install python-setuptools python-imaging python-ldap MySQL-python python-memcached python-urllib3
	
	cd seafile-server && ./setup-seafile.sh
	
	
	./seafile.sh start &&  ./seahub.sh start
	
	chk_firewall
	
	echo "/home/MyCloud/seafile-server/seafile.sh start" >> /etc/rc.d/rc.local
	echo "/home/MyCloud/seafile-server/seahub.sh start" >> /etc/rc.d/rc.local
	chmod u+x /etc/rc.d/rc.local
	
	osip=$(curl https://api.ip.sb/ip)
	echo "------------------------------------------------------"
	echo "install done, please visit: http://${osip}:8000"
	echo "thanks the scripts offered by xiaoz.If violate your rights, please contact me to delete.QQ:811972833"
	echo "------------------------------------------------------"
}

echo "##########install begin##########"

echo "1.install Seafile"
echo "2.uninstall Seafile"
echo "3.exit"
declare -i stype
read -p "please input:（1.2.3）:" stype

if [ "$stype" == 1 ]
	then
		if [ -e "/home/MyCloud" ]
			then
			echo "directory has exist, check if has installed."
			exit
		else
			echo "mkdir /home/MyCloud"
			mkdir -p /home/MyCloud
			install_sea
		fi
	elif [ "$stype" == 2 ]
		then
			/home/MyCloud/seafile-server/seafile.sh stop
			/home/MyCloud/seafile-server/seahub.sh stop
			rm -rf /home/MyCloud
			rm -rf /tmp/seahub_cache/*
			echo 'uninstall finish.'
			exit
	elif [ "$stype" == 3 ]
		then
			exit
	else
		echo "wrong input."
	fi	
