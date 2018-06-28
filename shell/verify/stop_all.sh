#!/bin/bash

cd `dirname $0`

. init.sh

function exit_on_err() {
    echo_blue "$1"
    eval "$1"
    if [[ 0 -ne $? ]]; then
        if [[ -z "$2" ]]; then
            echo_red "`date '+%F %T'` `caller 0 | awk '{print "("$1")"}'`run command failed: $1"
        else
            echo_red "`date '+%F %T'` `caller 0 | awk '{print "("$1")"}'` $2"
        fi
        exit 1
    fi
}

function simple_stop() {
    exit_on_err "./verify_server_operation/platform_develop_http.sh stop"
    exit_on_err "./verify_server_http/verify_server_http.sh stop"
    exit_on_err "./verify_server_http/old_verify_server_http.sh stop"
    exit_on_err "./db_server/featuredb.sh stop"
    exit_on_err "./featureExtractionWorker/server.sh stop"
    exit_on_err "./featureExtractionMaster/server.sh stop"
    exit_on_err "./msgcache/msgcache.sh stop"
    exit_on_err "./sysload/monitor_sysload_agent.sh stop"
    exit_on_err "./sysload/monitor_sysload_master.sh stop"
}

function stop_storage_server() {
    echo_blue "Killing Verify Log Collector"
    exit_on_err "./verify_log_collector/server.sh stop"


    echo_blue "Killing Mongo Image Storage"
    pid=`ps aux |grep -w "3rdparty/mongodb/mongod" | grep 27018 | grep -v grep | awk -F ' ' '{print $2}'`
    if [[ ! -z "${pid}" ]] ; then
        exit_on_err "kill ${pid}"
    fi

    while(( 1 ))
    do
        pid=`ps aux |grep -w "3rdparty/mongodb/mongod" | grep 27018 | grep -v grep | awk -F ' ' '{print $2}'`
        if [[ ! -z "${pid}" ]] ; then
            echo -e ". \c"
            sleep 1
        else
            break
        fi
    done
    echo ""

    echo_blue "Killing Mongo Feature Storage"
    pid=`ps aux |grep -w "3rdparty/featdb/mongod" | grep 27019 | grep -v grep | awk -F ' ' '{print $2}'`
    if [[ ! -z "${pid}" ]] ; then
        exit_on_err "kill ${pid}"
    fi

    while(( 1 ))
    do
        pid=`ps aux |grep -w "3rdparty/featdb/mongod" | grep 27019 | grep -v grep | awk -F ' ' '{print $2}'`
        if [[ ! -z "${pid}" ]] ; then
            echo -e ". \c"
            sleep 1
        else
            break
        fi
    done
    echo ""

    return 0
}

echo_blue "========================= Stopping Service ... ========================"

simple_stop
if [[ "all" == "$1" ]]; then
    stop_storage_server
fi

echo_blue "============================= All Stopped ============================="
