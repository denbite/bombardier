#!/bin/bash
source libs/echo.sh
source libs/exit.sh

function __internal_read_file {
    filename=$1
    callback=$2

    if [ -z $filename ]
    then
        exit_with_error "filename should be provided"
    fi

    if [ -z $callback ]
    then
        exit_with_error "callback function should be provided"
    fi

    while IFS= read -r line
    do
        $callback $line
    done < $filename

    if [ $? -ne 0 ]
    then
        exit_with_error "Something went wrong while parsing $filename file"
    fi
}

function parse_dns_records_for_domains {
    source_filename="${1:-domains.txt}"
    output_filename="${2:-ips.txt}"

    echo_default "Cleaning $output_filename ..."
    true > $output_filename

    echo_default "Generating IPs from the received domains in $source_filename ..."
    function callback_function {
        line=$1

        echo_default "Getting DNS record for $line"
        dig +short $line >> $output_filename
    }
    __internal_read_file $source_filename callback_function

    echo_green "Successfully generated $output_filename"
}

function read_file {
    __internal_read_file $1 $2
}