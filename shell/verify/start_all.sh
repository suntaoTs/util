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

BASE_DIR=`pwd`
cd py3.6/bin
source activate
cd $BASE_DIR

./stop_all.sh

export LD_LIBRARY_PATH=$PWD/native/
export PATH=$PWD/linux_x86_64/bin:$PATH
export RACK_ENV=deploy

VERSION=`cat version |head -1`
echo ""

echo_blue "========================= Starting Service ... ========================"

echo_yellow "Version: ${VERSION}"

echo_blue "Start Mongodb Image Server"
./3rdparty/mongodb/mongo_setting.sh > /dev/null
sleep 1
echo "started"
echo_blue "Start Mongodb Feature Server"
./3rdparty/featdb/mongo_setting.sh > /dev/null
echo "started"

exit_on_err "./verify_log_collector/server.sh start"
exit_on_err "./sysload/monitor_sysload_master.sh start"
exit_on_err "./msgcache/msgcache.sh start"
exit_on_err "./sysload/monitor_sysload_agent.sh start"
sleep 1

echo_blue "Init MongoDB"
echo -e "use test\ndb.createCollection(\"tmpimages\",{capped:true,size:1000000000,max:50000})" | ./3rdparty/mongodb/mongo 127.0.0.1:27018 > /dev/null
echo -e "use test\ndb.tmpimages.ensureIndex({\"uuid\":1})" | ./3rdparty/mongodb/mongo 127.0.0.1:27018 > /dev/null
echo -e "use test\ndb.images.ensureIndex({\"uuid\":1})" | ./3rdparty/mongodb/mongo 127.0.0.1:27018 > /dev/null
echo "inited"

exit_on_err "./db_server/featuredb.sh start"
exit_on_err "./featureExtractionMaster/server.sh start"
exit_on_err "./featureExtractionWorker/server.sh start"
sleep 1
exit_on_err "./verify_server_http/verify_server_http.sh start"
exit_on_err "./verify_server_http/old_verify_server_http.sh start"
sleep 1
exit_on_err "./verify_server_operation/platform_develop_http.sh start"

# 延迟1s检查，worker可能正在启动中
sleep 1
./check_all.sh

if [ $? = 0 ]; then
    echo_blue "============================ Service Started =========================="
else
    read -p "Stop Service? (y/n): " yn
    case $yn in
        [Yy]* )
        ./stop_all.sh break;;
    esac
fi
