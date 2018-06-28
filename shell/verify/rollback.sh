#!/bin/bash

cd `dirname $0`

function usage() {
    echo "$0 [-p|--path <path>]"
    echo "  -p|--path       Verify Server backup path (directory which include 'verify_server')." 
}

function exit_on_err() {
    echo "$1"
    eval "$1" 2>&1 >/dev/null
    if [[ 0 -ne $? ]]; then
        if [[ -z "$2" ]]; then
            echo "`date '+%F %T'` `caller 0 | awk '{print "("$1")"}'`run command failed: $1"
        else
            echo "`date '+%F %T'` `caller 0 | awk '{print "("$1")"}'` $2"
        fi
        exit 1
    fi
}

#######################################################################
# checking

echo -e "\033[34m# checking: ------------------------------------------------------------\033[0m"

[[ -z ${INSTALL_USER} ]] && INSTALL_USER="admin"

if [ -e "/var/Xh89skd_9Kgh8HJ_temp" ]; then
    source /var/Xh89skd_9Kgh8HJ_temp
fi

INSTALL_PATH="/${INSTALL_USER}/StaticServer"
BACK_PATH="/${INSTALL_USER}/Backup/StaticServer"
VERIFY_SERVER_BACKUP_DIR=/${BACK_PATH}/last_backup_link

# get parameters from command line
ARGS=`getopt -o hp: -l "help,path:" -- "$@"`
eval set -- "${ARGS}"

while true;
do
    case "$1" in
        -h|--help) 
            usage
            exit 0
            shift
            ;;
        -p|--path) 
            VERIFY_SERVER_BACKUP_DIR=$2
            shift 2
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "invalie parameter option $1"
            exit 1
            ;;
    esac
done

echo "install user:$INSTALL_USER"
echo "install path:$INSTALL_PATH"
echo "backup path:$VERIFY_SERVER_BACKUP_DIR"

exit_on_err "test '$USER' == 'root'" "Please change user to 'root'!"

if [[ ! -e "${VERIFY_SERVER_BACKUP_DIR}/verify_server}" ]]; then
    echo "backup path: ${VERIFY_SERVER_BACKUP_DIR}/verify_server is inexistent"
fi

#######################################################################
# rollback

echo -e "\033[34m# stop current verify_server: ------------------------------------------\033[0m"

# delete from crontab
crontab -l > crontab_script
if [ 0 -eq $? ]; then
    exit_on_err "sed -i '/verify_server\/check_alive.sh/d' crontab_script"
    exit_on_err "crontab crontab_script"
fi

# stop old verify_server (cuda7)
if [[ -d '/SenseTime/StaticServer/verify_server' ]]; then
    ( cd /SenseTime/StaticServer/verify_server && ./stop_all.sh all )
fi

# stop unstandard verify_sever (yiyan)
if [[ -d '/verify_server' ]]; then
    ( cd /verify_server && ./stop_all.sh all )
fi

# stop standard verify_server
if [[ -d "${INSTALL_PATH}/verify_server" ]]; then
    ( cd ${INSTALL_PATH}/verify_server && ./stop_all.sh all )
fi

# stop redis
redis=`pgrep -f "3rdparty/redis/redis-server"`
if [ $? = 0 ];  then
    exit_on_err "kill $redis"
fi

# stop mongo (image)
mongo=`pgrep -f "3rdparty/mongodb/mongod"`
if [ $? = 0 ]; then
    exit_on_err "kill $mongo"
fi

# stop mongo (featdb)
mongo=`pgrep -f "3rdparty/featdb/mongod"`
if [ $? = 0 ]; then
    exit_on_err "kill $mongo"
fi

echo -e "\033[34m# remove current verify_server: ----------------------------------------\033[0m"

exit_on_err "rm -rf ${INSTALL_PATH}/verify_server"

echo -e "\033[34m# rollbackup: ----------------------------------------------------------\033[0m"

exit_on_err "cp -rP ${VERIFY_SERVER_BACKUP_DIR}/verify_server ${INSTALL_PATH}/"

echo -e "\033[34m# permission setting: -------------------------------------------------\033[0m"

exit_on_err "chown -R ${INSTALL_USER}:${INSTALL_USER} ${INSTALL_PATH}"

echo -e "\033[34m# add to crontab: -----------------------------------------------------\033[0m"

CHECK_ALIVE="${INSTALL_PATH}/verify_server/check_alive.sh"

crontab -l > crontab_script
if [ 0 -ne $? ]; then
    exit_on_err "touch crontab_script"
fi

exit_on_err "sed -i '/verify_server\/check_alive.sh/d' crontab_script"
CMD="* * * * * su ${INSTALL_USER} -c '${CHECK_ALIVE}' 2>&1 >/dev/null"
echo "${CMD}" | tee -a crontab_script

for time in {20..40..20}
do
    CMD="* * * * * sleep ${time};su ${INSTALL_USER} -c '${CHECK_ALIVE}' 2>&1 >/dev/null"
    echo "${CMD}" | tee -a crontab_script
done

exit_on_err "crontab crontab_script"

#######################################################################
# finish

echo -e "\033[36m\n$0 finished\n\033[0m"
