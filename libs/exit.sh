#!/bin/bash
source echo.sh

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