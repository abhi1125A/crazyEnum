#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

function print_red {
    local text="$1"
    echo -e "${RED}${text}${NC}"
}

function print_green {
	local text="$1"
	echo -e "${GREEN}${text}${NC}"
}

ip_regex="^([0-9]{1,3}\.){3}[0-9]{1,3}$"

function host_scan {
	ip_address=$(echo $1 | cut -d '/' -f1)
	print_red "Host Discovery for subnet $ip_address started"
	sudo nmap -PE -sn $1 -oN ./$directory/hosts/sub_$ip_address.nmap | grep "for" | cut -d " " -f5 > ./$directory/hosts.txt
	cat ./$directory/hosts.txt >> ./$directory/$ip_address.alive_hosts.txt
	hosts=$(cat ./$directory/hosts.txt)
	print_green "Host Discovery for $ip_address completed"
	for i in $hosts
	do
		print_red "Port Scanning for $i started"
		port_scan $i
	done
	print_green "Port Scanning for subnet $ip_address completed"
	return
}

function port_scan {
	mkdir -p ./$directory/ports/$ip_address
	sudo nmap -sS -Pn -n $1 -oN ./$directory/ports/$ip_address/$1.nmap --disable-arp-ping | grep "open" > ./$directory/$1.oports.txt
	print_green "Port Scanning for $1 completed"
	print_red "Service Scanning for $1 started"
	service_scan $1
	return
}

function service_scan {
	mkdir -p ./$directory/service_scans/$ip_address
	ports=$(cat ./$directory/ports/$ip_address/$1.nmap | grep '[0-9]/tcp' | cut -d '/' -f1)
	port=$(echo $ports | tr " " ",")
	sudo nmap -sV -sC -Pn -n $1 -p $port --disable-arp-ping -oN ./$directory/service_scans/$ip_address/$1.nmap | grep "open" > ./$directory/$1.oports.txt
	print_green "Service Scanning for $1 completed"
	return
}

function helper {
	print_green "Usage: \n\t help: To get this help menu\n\t hosts: To print all alive hosts\n\t <IP>: Print open ports of entered alive host"
	return
}

function execute_command {
	if [[ $1 == "hosts" ]]
	then
		print_red "$(paste -d '\t' ./$directory/*.alive_hosts.txt | column -t)"
	elif [[ $1 =~ $ip_regex ]]
	then
	ip=$1
	print_green "$(cat ./$directory/service_scans/${ip%.*}.0/${ip}.nmap)"
	fi
}


function take_command {
	helper
	count=1
	while [[ count -lt 2 ]]
	do
		read -p "Scanner[~]# " command
		if [ "$command" == "exit" ]
		then
			((count++))
		elif [ "$command" == "help" ]
		then
			helper
		else
			execute_command "$command"
		fi
	done
}

function make_dir {
	if [ -e "scanning" ]
	then
		read -p "Enter the directory name where you want to save the results: " dir_name
		mkdir -p $dir_name/hosts $dir_name/ports $dir_name/service_scans
		directory="$dir_name"
		return
	else
		mkdir -p scanning/hosts scanning/ports scanning/service_scans
		directory="scanning"
		return
	fi

}

function main {
	if [ $# -lt 1 ]
	then
		echo "Usage ./scanning.sh [ subnet 1 ] [ subnet 2 ] ..... [ subnet n ] "
		echo "Example: ./scanning.sh 192.168.58.0/24 172.16.16.0/24"
	else 
		python3 banner.py
		make_dir
		for arg in "$@"
		do
			array+=("$arg")
		done

		for subnet in "${array[@]}"
		do
			host_scan $subnet
		done
		take_command
	fi
}
main "$@"
