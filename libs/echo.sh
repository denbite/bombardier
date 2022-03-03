#!/bin/bash

NO_COLOR=0
RED_COLOR=31
GREEN_COLOR=32

function __internal_echo_with_color {
    received_color=$1
    text=$2

	start_color="\033[${received_color}m"
	end_color="\033[0m"

	echo -e "${start_color}${text}${end_color}"
}

function echo_red {
    __internal_echo_with_color $RED_COLOR "$1"
}

function echo_green {
    __internal_echo_with_color $GREEN_COLOR "$1"
}

function echo_default {
    __internal_echo_with_color $NO_COLOR "$1"
}