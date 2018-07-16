#!/bin/bash

cd `dirname $0`

. echo_color.sh

VERIFY_SERVER_USER=admin

if [ `whoami` != ${VERIFY_SERVER_USER} ]; then
    echo_red "Must Run as ${VERIFY_SERVER_USER}!"
    exit 1
fi
