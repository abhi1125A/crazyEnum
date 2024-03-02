#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

function print_red {
    local text="$1"
    echo -e "${RED}${text}${NC}"
}

function print_green {
	local text="$1"
	echo -e "${GREEN}${text}${NC}"
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

take_command
