#!/bin/bash

cd `dirname $0`

. echo_color.sh

. init.sh

hasFailedService=0

if ! [ -d /usr/local/cuda-8.0 ]; then
    echo_red "Cuda8.0 Not Found!"
fi

pid=`./verify_log_collector/server.sh status | awk -F ' ' '{print $2}'`
if [[ ! -z "${pid}" && ${pid} =~ ^[0-9] ]]; then
  echo_green "Verify Log Collector Server is Running!"
else
  echo_red "Verify Log Collector Not Running!"
  hasFailedService=1
fi

port_set=(9002 9003 9004 9005)
for port in ${port_set[@]}; do
  pid=`./verify_server_http/verify_server_http.sh status ${port} | awk -F ' ' '{print $2}'`
  if [[ ! -z "${pid}" && ${pid} =~ ^[0-9] ]]; then
    echo_green "Restful Api Server ${port} is Running!"
  else
    echo_red "Restful Api Server ${port} Not Running!"
  hasFailedService=1
  fi
done

pid=`./verify_server_http/old_verify_server_http.sh status | awk -F ' ' '{print $2}'`
if [[ ! -z "${pid}" && ${pid} =~ ^[0-9] ]]; then
  echo_green "Old Restful Api Server is Running!"
else
  echo_red "Old Restful Api Server Not Running!"
  hasFailedService=1
fi

pid=`./verify_server_operation/platform_develop_http.sh status | awk -F ' ' '{print $2}'`
if [[ ! -z "${pid}" && ${pid} =~ ^[0-9] ]]; then
  echo_green "Platform Develop Http Server is Running!"
else
  echo_red "Platform Develop Http Not Running!"
  hasFailedService=1
fi

pid=`./db_server/featuredb.sh status | awk -F ' ' '{print $2}'`
if [[ ! -z "${pid}" && ${pid} =~ ^[0-9] ]]; then
  echo_green "FeatureDB Server is Running!"
else
  echo_red "FeatureDB Server Not Running!"
  hasFailedService=1
fi

pid=`./featureExtractionMaster/server.sh status | awk -F ' ' '{print $2}'`
if [[ ! -z "${pid}" && ${pid} =~ ^[0-9] ]]; then
  echo_green "Feature Extraction Master is Running!"
else
  echo_red "Feature Extraction Master Not Running!"
  hasFailedService=1
fi

gpu_num=`nvidia-smi -L | wc -l`
for ((wid=0; wid < ${gpu_num}; wid++))
do
  pid=`./featureExtractionWorker/server.sh status ${wid} | awk -F ' ' '{print $2}'`
    
  if [[ ! -z "${pid}" && ${pid} =~ ^[0-9] ]]; then
    echo_green "Feature Extraction Worker ${wid} is Running!"
  else
    echo_red "Feature Extraction Worker ${wid} Not Running!"
    hasFailedService=1
#
#    if [ -f "log/worker_${wid}_stdout" ]; then
#      keyerr=`tail -1 log/worker_${wid}_stdout`
#      if [[ ! -z "${keyerr}" ]] ; then
#        echo_red "Last Log: ${keyerr}"
#        fi
#    fi
  fi
done

pid=`./msgcache/msgcache.sh status | awk -F ' ' '{print $2}'`
if [[ ! -z "${pid}" && ${pid} =~ ^[0-9] ]]; then
  echo_green "Message Cache is Running!"
else
  echo_red "Message Cache Not Running!"
  hasFailedService=1
fi

pid=`./sysload/monitor_sysload_master.sh status | awk -F ' ' '{print $2}'`
if [[ ! -z "${pid}" && ${pid} =~ ^[0-9] ]]; then
  echo_green "System Load Master is Running!"
else
  echo_red "System Load Master Not Running!"
  hasFailedService=1
fi

pid=`./sysload/monitor_sysload_agent.sh status | awk -F ' ' '{print $2}'`
if [[ ! -z "${pid}" && ${pid} =~ ^[0-9] ]]; then
  echo_green "System Load Agent is Running!"
else
  echo_red "System Load Agent Not Running!"
  hasFailedService=1
fi

pgrep -f "3rdparty/mongodb/mongod" > /dev/null
if ! [ $? = 0 ]; then
  echo_red "Mongodb Image Storage Not Running!"
  hasFailedService=1
else
  echo_green "Mongodb Image Storage is Running!"
fi

pgrep -f "3rdparty/featdb/mongod" > /dev/null
if ! [ $? = 0 ]; then
  echo_red "Mongodb Feature Storage Not Running!"
  hasFailedService=1
else
  echo_green "Mongodb Feature Storage is Running!"
fi

if [ $hasFailedService = 0 ]; then
  echo_green "All Components are Running."
else
  echo_red "Not all components are running, please check related logs!!!"
fi

exit $hasFailedService
