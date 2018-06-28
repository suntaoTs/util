#!/bin/bash
. echo_color.sh
cd `dirname $0`

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

export LD_LIBRARY_PATH=$PWD/native/
export PATH=$PWD/linux_x86_64/bin:$PATH
export RACK_ENV=deploy

BASE_DIR=`pwd`
cd py3.6/bin
source activate
cd ${BASE_DIR}

exit_on_err "./verify_server_operation/platform_develop_http.sh keepalive"

. init.sh

pgrep -f "start_all.sh" > /dev/null
if [[ $? == 0 ]]; then
  exit 0
fi

echo_blue "checking mongo image storage"
pgrep -f "3rdparty/mongodb/mongod" > /dev/null
if ! [[ $? == 0 ]]; then
  echo "start image mongod"
  ./3rdparty/mongodb/mongo_setting.sh > /dev/null
  sleep 1
  echo -e "use test\ndb.createCollection(\"tmpimages\",{capped:true,size:1000000000,max:50000})" | ./3rdparty/mongodb/mongo 127.0.0.1:27018 > /dev/null
  echo -e "use test\ndb.tmpimages.ensureIndex({\"uuid\":1})" | ./3rdparty/mongodb/mongo 127.0.0.1:27018 > /dev/null
  echo -e "use test\ndb.images.ensureIndex({\"uuid\":1})" | ./3rdparty/mongodb/mongo 127.0.0.1:27018 > /dev/null
fi

echo_blue "checking mongo feature storage"
pgrep -f "3rdparty/featdb/mongod" > /dev/null
if ! [ $? = 0 ]; then
  echo "start feature mongod"
  ./3rdparty/featdb/mongo_setting.sh restart > /dev/null
fi

exit_on_err "./verify_log_collector/server.sh keepalive"
exit_on_err "./sysload/monitor_sysload_master.sh keepalive"
exit_on_err "./sysload/monitor_sysload_agent.sh keepalive"
exit_on_err "./msgcache/msgcache.sh keepalive"
exit_on_err "./db_server/featuredb.sh keepalive"
exit_on_err "./featureExtractionMaster/server.sh keepalive"

gpu_num=`nvidia-smi -L | wc -l`
for ((wid=0; wid < ${gpu_num}; wid++))
do
    exit_on_err "./featureExtractionWorker/server.sh keepalive ${wid}"
done

exit_on_err "./verify_server_http/verify_server_http.sh keepalive"
exit_on_err "./verify_server_http/old_verify_server_http.sh keepalive"
