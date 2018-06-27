#!/bin/bash

cd `dirname $0`

MONGO_BIN="./3rdparty/mongodb/mongo"
DUMP_BIN="./3rdparty/mongodb/mongodump"
RESTORE_BIN="./3rdparty/mongodb/mongorestore"
BACKUP_DIR="${PWD}/backup"
NATIVE="${PWD}/native"

#############################################
# echo_color
RED_COLOR='\E[31m'    # red
GREEN_COLOR='\E[32m'  # green
YELLOW_COLOR='\E[33m' # yellow
BLUE_COLOR='\E[34m'   # blue
PINK_COLOR='\E[35m'   # pink
RES='\E[0m'           # finish

echo_red()
{
    content=$1
    echo -e "${RED_COLOR}${content}${RES}"
}

echo_green()
{
    content=$1
    echo -e "${GREEN_COLOR}${content}${RES}"
}

echo_yellow()
{
    content=$1
    echo -e "${YELLOW_COLOR}${content}${RES}"
}

echo_blue()
{
    content=$1
    echo -e "${BLUE_COLOR}${content}${RES}"
}

echo_pink()
{
    content=$1
    echo -e "${PINK_COLOR}${content}${RES}"
}

###############################################
# 0 for ok
# 1 for bad
check_bin_ldd()
{
	key="not found"
	bin=${1}
	res=`ldd ${bin} | grep "${key}"`
	if [ -z ${res} ]
	then
		return 0
	else
		return 1
	fi
}

#############################################################################################################################
# from http://stackoverflow.com/questions/2829613/how-do-you-tell-if-a-string-contains-another-string-in-unix-shell-scripting
contains()
{
    string="$1"
    substring="$2"
    if test "${string#*$substring}" != "$string"
    then
        return 0    # $substring is in $string
    else
        return 1    # $substring is not in $string
    fi
}


check_port_open()
{
    ip=$1
    port=$2

    echo "timeout 1 bash -c \"cat < /dev/null > /dev/tcp/${ip}/${port}\""

    timeout 1 bash -c "cat < /dev/null > /dev/tcp/${ip}/${port}"
    return $?
}


usage()
{
	echo -e "Usage:$0 src_host dst_host collection1 [collection2 ...]"
}


###################################################
# ===> start here
export LD_LIBRARY_PATH="${NATIVE}"

if [ $# -lt 3 ]
then
    usage
    exit 0
fi

# 0. check mongodump & mongorestore exist
if [ ! -f ${DUMP_BIN} ]
then
	echo_red "${DUMP_BIN} not exist!"
	exit 1
fi

if [ ! -f ${RESTORE_BIN} ]
then
	echo_red "${RESTORE_BIN} not exist!"
	exit 2
fi

###################################################
# 1. checkout mongodb

src_host="$1"
src_ip=`echo $src_host | awk -F: '{print $1}'`
src_port=`echo $src_host | awk -F: '{print $2}'`

dst_host="$2"
dst_ip=`echo $dst_host | awk -F: '{print $1}'`
dst_port=`echo $dst_host | awk -F: '{print $2}'`

check_port_open "${src_ip}" ${src_port}
check_port_open "${dst_ip}" ${dst_port}


###################################################
# 2. backup data
mongo_db="featuredb"
dbinfo="dbinfo"

if [ -d ${BACKUP_DIR} ]
then
    rm -r ${BACKUP_DIR}
fi

echo_green "------ backup and restore begin ------"
# 2.1 dump collection: featuredb_xx
for ((i=3; i<=$#; ++i))
do
    echo "backup collection:${!i}"
	echo "${DUMP_BIN} --host=${src_host} --db=${mongo_db} --collection=${!i} --out=${BACKUP_DIR}"
    #${DUMP_BIN} --host=${src_host} --db=${mongo_db} --collection=${!i} --out=${BACKUP_DIR}
done

# 2.2 dump collection: dbinfo
dbnames=""
for ((i=3; i<=$#; ++i))
do
    dbname=`echo ${!i} | sed 's/featuredb_//g'`
    echo "backup dbinfo:${dbname}"
    if [ -z "${dbname}" ]
    then
        continue
    fi
    dbnames="${dbnames}\"$dbname\","
done
dbnames=${dbnames:0:-1}
echo "${DUMP_BIN} --host=${src_host} --db=${mongo_db} --collection=${dbinfo} --query="{db:{\$in:[${dbnames}]}}" --out=${BACKUP_DIR}"
${DUMP_BIN} --host=${src_host} --db=${mongo_db} --collection=${dbinfo} --query="{db:{\$in:[${dbnames}]}}" --out=${BACKUP_DIR}

# 2.3 restore db: featuredb
echo "${RESTORE_BIN} --host=${dst_host} --dir=${BACKUP_DIR}"
${RESTORE_BIN} --host=${dst_host} --dir=${BACKUP_DIR}
echo_green "------ backup and restore finished! ------"
