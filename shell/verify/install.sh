#!/bin/bash

cd `dirname $0`

. echo_color.sh

function log() {
    echo "`date '+%F %T'` `caller 0 | awk '{print $2"|"$1"|"}'`$1"
}

function exit_on_err() {
    echo "$1"
    eval "$1" 2>&1 >/dev/null
    if [[ 0 -ne $? ]]; then
        if [[ -z "$2" ]]; then
            echo_red "`date '+%F %T'` `caller 0 | awk '{print "("$1")"}'`run command failed: $1"
        else
            echo_red "`date '+%F %T'` `caller 0 | awk '{print "("$1")"}'` $2"
        fi
        exit 1
    fi
}

function change_limits_nofile()
{
    sed -i '/soft nofile/d' '/etc/security/limits.conf'
    sed -i '/hard nofile/d' '/etc/security/limits.conf'
    echo "* soft nofile 65535" | tee -a '/etc/security/limits.conf'
    echo "* hard nofile 65535" | tee -a '/etc/security/limits.conf'
}

function get_os_name_version() {
    if [[ -e /etc/lsb-release ]]; then
        echo "ubuntu `grep DISTRIB_RELEASE /etc/lsb-release | awk -F '=' '{print $2}'`" 
    elif [[ -e /etc/centos-release ]]; then
        grep 7.4 /etc/centos-release > /dev/null
        if [ $? = 0 ]; then
            echo "centos 7.4"
        else
            grep 7.2 /etc/centos-release > /dev/null
            if [ $? = 0 ]; then
                echo "centos 7.2"
            else
                grep 6.7 /etc/centos-release > /dev/null
                if [ $? = 0 ]; then
                    echo "centos 6.7"
                fi
            fi
        fi
    fi
}

function is_supported_os() {
    local os=`get_os_name_version`
    #local supported=`echo ${os} | grep -oP "ubuntu 14.04|centos 7.2|centos 6.7"`
    local supported='no'

    if [ x"ubuntu 14.04" = x"${os}" ]; then
        supported="yes"
    fi

    if [ x"centos 7.2" = x"${os}" ]; then
        supported="yes"
    fi

    if [ x"centos 7.4" = x"${os}" ]; then
        supported="yes"
    fi

    if [ x"centos 6.7" = x"${os}" ]; then
        supported="yes"
    fi

    echo ${supported}
}

#######################################################################
# checking
exit_on_err "test $(whoami) == 'root'" "Please change user to 'root'!"
#exit_on_err "test '$USER' == 'root'" "Please change user to 'root'!"

[[ -z ${INSTALL_USER} ]] && INSTALL_USER="admin"

if [ -e "/var/Xh89skd_9Kgh8HJ_temp" ]; then
    source /var/Xh89skd_9Kgh8HJ_temp
fi

exit_on_err "test ! -z '${INSTALL_USER}'" "Install user is not setted"
exit_on_err "test 'yes' == '`is_supported_os`'" "Not supported OS: `get_os_name_version`"

INSTALL_PATH="/${INSTALL_USER}/StaticServer"
BACK_PATH="/${INSTALL_USER}/Backup/StaticServer"

echo "install user:$INSTALL_USER"
echo "install path:$INSTALL_PATH"
echo "OS: `get_os_name_version`"

exit_on_err "mkdir -p ${INSTALL_PATH}"
exit_on_err "mkdir -p ${BACK_PATH}"

#######################################################################
# uinstall and install

echo_blue "# disable tty requirement to run sudo: ---------------------------------"

sed -i '/Defaults[ \t]*requiretty.*/d' /etc/sudoers

echo_blue "# stop current verify_server: ------------------------------------------"

# delete from rc.local
if [ -f /etc/rc.d/rc.local ]; then
    #centos
    sed -i '/verify_server\/check_alive.sh/d' '/etc/rc.d/rc.local'
    sed -i '/verify_server\/start_all.sh/d' '/etc/rc.d/rc.local'
    sed -i '/mongo_setting.sh/d' '/etc/rc.d/rc.local'
else
    # ubuntu
    sed -i '/verify_server\/check_alive.sh/d' '/etc/init.d/rc.local'
    sed -i '/verify_server\/start_all.sh/d' '/etc/init.d/rc.local'
    sed -i '/mongo_setting.sh/d' '/etc/init.d/rc.local'
fi

# delete from crontab
crontab -l > crontab_script
if [ 0 -eq $? ]; then
    exit_on_err "sed -i '/verify_server\/check_alive.sh/d' crontab_script"
    exit_on_err "crontab crontab_script"
fi

# stop old verify_server (cuda7)
if [[ -d '/SenseTime/StaticServer/verify_server' ]]; then
    ( cd /SenseTime/StaticServer/verify_server && su ${INSTALL_USER} -c './stop_all.sh all' )
fi

# stop unstandard verify_sever (yiyan)
if [[ -d '/verify_server' ]]; then
    ( cd /verify_server && su ${INSTALL_USER} -c './stop_all.sh all' )
fi

# stop standard verify_server
if [[ -d "${INSTALL_PATH}/verify_server" ]]; then
    ( cd ${INSTALL_PATH}/verify_server && su ${INSTALL_USER} -c './stop_all.sh all' )
fi

# stop redis
exit_on_err "./sysload/monitor_sysload_master.sh stop"
exit_on_err "./msgcache/msgcache.sh stop"

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

echo_blue "# backup current verify_server: ----------------------------------------"

TIMESTAMP=$(date +%Y-%m-%d_%H%M%S)

    
# backup verify_server (old)
if [  -d "/SenseTime/StaticServer/verify_server" ]; then
    VERIFY_SERVER_BACKUP_DIR="${BACK_PATH}/old_$TIMESTAMP"
    exit_on_err "mkdir -p $VERIFY_SERVER_BACKUP_DIR"
    exit_on_err "mv /SenseTime/StaticServer/verify_server $VERIFY_SERVER_BACKUP_DIR"
fi
    
# backup verify_server (yiyuan)
if [  -d "/verify_server" ]; then
    VERIFY_SERVER_BACKUP_DIR="${BACK_PATH}/yiyuan_$TIMESTAMP"
    exit_on_err "mkdir -p $VERIFY_SERVER_BACKUP_DIR"
    exit_on_err "mv /verify_server $VERIFY_SERVER_BACKUP_DIR"
fi

# backup verify_server (standard)
if [  -d "${INSTALL_PATH}/verify_server" ]; then
    VERIFY_SERVER_BACKUP_DIR="${BACK_PATH}/standard_$TIMESTAMP"
    exit_on_err "mkdir -p $VERIFY_SERVER_BACKUP_DIR"
    exit_on_err "mv ${INSTALL_PATH}/verify_server $VERIFY_SERVER_BACKUP_DIR"
fi

exit_on_err "rm -rf ${BACK_PATH}/last_backup_link"
exit_on_err "ln -sf ${VERIFY_SERVER_BACKUP_DIR} ${BACK_PATH}/last_backup_link"

echo_blue "# install verify_server: ----------------------------------------------"

exit_on_err "cp -rP ../verify_server ${INSTALL_PATH}"
exit_on_err "cp ${INSTALL_PATH}/verify_server/VS.conf /etc/ld.so.conf.d"
exit_on_err "ldconfig"

NGINX_PATH="/usr/local/nginx"
if [[ ! -d ${NGINX_PATH} ]]; then
  echo "nginx not exist,config nginx fail"
  exit 1
fi

NGINX_CONF="${NGINX_PATH}/conf"

NGINX_CONTENT="    include /usr/local/nginx/conf/nginx.verify.conf;"
NGINX_CONF_STR=`cat ${NGINX_CONF}/nginx.conf | grep "^[[:space:]]*include[[:space:]]*/usr/local/nginx/conf/nginx.verify.conf;"`
if [ -z "$NGINX_CONF_STR" ]; then
	TARGET_LINS=`sed -n '/^[[:space:]]*server[[:space:]]*{/=' $NGINX_CONF/nginx.conf | sed -n "1"p`
	sed -i "${TARGET_LINS}i\\${NGINX_CONTENT}" ${NGINX_CONF}/nginx.conf
fi

exit_on_err "mv ${INSTALL_PATH}/verify_server/nginx.verify.conf ${NGINX_CONF}"


echo_blue "# restore data: -------------------------------------------------------"
if [[ ! -d ${INSTALL_PATH}/data/mongodb/ ]];then
    exit_on_err "mkdir -p ${INSTALL_PATH}/data/mongodb/"
fi

if [[ -d ${VERIFY_SERVER_BACKUP_DIR}/verify_server/3rdparty/mongodb/data ]]; then
    exit_on_err "cp -rP ${VERIFY_SERVER_BACKUP_DIR}/verify_server/3rdparty/mongodb/data ${INSTALL_PATH}/data/mongodb/"
fi

if [[ ! -d ${INSTALL_PATH}/data/featdb/ ]];then
    exit_on_err "mkdir -p ${INSTALL_PATH}/data/featdb/"
fi

if [[ -d ${VERIFY_SERVER_BACKUP_DIR}/verify_server/3rdparty/featdb/data ]]; then
    exit_on_err "cp -rP ${VERIFY_SERVER_BACKUP_DIR}/verify_server/3rdparty/featdb/data ${INSTALL_PATH}/data/featdb/"
fi

if [[ ! -d ${VERIFY_SERVER_BACKUP_DIR}/verify_server/3rdparty/featdb/data ]]; then
    if [[ -d ${VERIFY_SERVER_BACKUP_DIR}/verify_server/3rdparty/mongodb/data ]]; then
        exit_on_err "${INSTALL_PATH}/verify_server/backup.sh"
    fi
fi

exit_on_err "chown -R ${INSTALL_USER}:${INSTALL_USER} ${INSTALL_PATH}"

echo_blue "# restore license -----------------------------------------------------"

#echo_blue "# system setting (for centos) -----------------------------------------"
#
#exit_on_err "chmod a+r /sys/devices/system/cpu/cpu*/cpufreq/*"

echo_blue "# add to start up: ----------------------------------------------------"

CLOSE_THP="${INSTALL_PATH}/verify_server/huge_page_close.sh"
exit_on_err "${CLOSE_THP}"
#change_limits_nofile

echo_blue "# add to crontab: -----------------------------------------------------"

CHECK_ALIVE="${INSTALL_PATH}/verify_server/check_alive.sh"

crontab -l > crontab_script
if [ 0 -ne $? ]; then
    exit_on_err "touch crontab_script"
fi

exit_on_err "sed -i '/board_serial/d' crontab_script"
CHMOD="* * * * * chmod a+r /sys/class/dmi/id/board_serial 2>&1 >/dev/null"
echo "${CHMOD}" | tee -a crontab_script

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

echo_green "\n$0 finished\n"
