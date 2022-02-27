#!/bin/bash

function __internal_read_file {
    filename=$1;
    callback=$2;

    if [ -z $filename ]
    then
        echo "filename should be provided"
        exit 1
    fi

    if [ -z $callback ]
    then
        echo "callback function should be provided"
        exit 1
    fi

    while IFS= read -r line
    do
        $callback $line
    done < $filename

    if [ $? -ne 0 ]
    then
        echo "Something went wrong while parsing $filename file"
        exit 1
    fi
}

function parse_dns_records_for_domains {
    source_filename="${1:-domains.txt}"
    output_filename="${2:-ips.txt}"

    echo "Cleaning $output_filename ..."
    true > $output_filename

    echo "Generating IPs from the received domains in $source_filename ..."
    function callback_function {
        line=$1

        echo "Getting DNS record for $line"
        dig +short $line >> $output_filename
    }
    __internal_read_file $source_filename callback_function

    echo "Successfully generated $output_filename"
}

function read_file {
    __internal_read_file $1 $2
}