#!/bin/bash

function exit_on_err() {
#    echo "$1"
    eval "$1" > /dev/null
    if [[ 0 -ne $? ]]; then
        echo "run command failed: $1"
        exit 1
    fi
}


#############################################
# echo_color
ECHO_COLOR_RED='\E[31m'    # red
ECHO_COLOR_GREEN='\E[32m'  # green
ECHO_COLOR_YELLOW='\E[33m' # yellow
ECHO_COLOR_BLUE='\E[34m'   # blue
ECHO_COLOR_PINK='\E[35m'   # pink
ECHO_COLOR_END='\E[0m'     # finish

function echo_red() {
    echo -e "${ECHO_COLOR_RED}${1}${ECHO_COLOR_END}"
}

function echo_green() {
    echo -e "${ECHO_COLOR_GREEN}${1}${ECHO_COLOR_END}"
}

function echo_yellow() {
    echo -e "${ECHO_COLOR_YELLOW}${1}${ECHO_COLOR_END}"
}

function echo_blue() {
    echo -e "${ECHO_COLOR_BLUE}${1}${ECHO_COLOR_END}"
}

function echo_pink() {
    echo -e "${ECHO_COLOR_PINK}${1}${ECHO_COLOR_END}"
}