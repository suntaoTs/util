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
	echo -e "Usage:$0 collection"
}


###################################################
# ===> start here
export LD_LIBRARY_PATH="${NATIVE}"

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
# 1. start featdb and mongodb
echo_green "1. start mongodb server ..."
./3rdparty/mongodb/mongo_setting.sh > /dev/null
sleep 3

check_port_open "127.0.0.1" 27018
if [ $? -ne 0 ]
then
    echo "127.0.0.1:27018 is not open"
    exit 1
else
    echo "127.0.0.1:27018 check ok"
fi

echo_green "2. start featdb server ..."
./3rdparty/featdb/mongo_setting.sh > /dev/null
sleep 3

check_port_open "127.0.0.1" 27019
if [ $? -ne 0 ]
then
    echo "127.0.0.1:27018 s not open"
    exit 1
else
    echo "127.0.0.1:27018 check ok"
fi

###################################################
# 2. variables
src_mongo_host="127.0.0.1:27018"
src_mongo_db="featuredb"

dst_mongo_host="127.0.0.1:27019"

###################################################
# 3. backup data
echo_green "------ backup and restore begin ------"

# 3.0 backup dbinfo
${DUMP_BIN} --host=${src_mongo_host} --db=featuredb --collection=dbinfo --out=- | ${RESTORE_BIN} --host=${dst_mongo_host} --db=featuredb --collection=dbinfo --dir=- --drop

for collection in `echo -e "use featuredb\nshow collections" | ./3rdparty/mongodb/mongo 127.0.0.1:27018 | grep "featuredb_"`
do
	# 3.1 backup featuredb_xxx
	echo "backup coll:$collection"
	echo "${DUMP_BIN} --host=${src_mongo_host} --db=${src_mongo_db} --collection=${collection} --out=- | ${RESTORE_BIN} --host=${dst_mongo_host} --db=${src_mongo_db} --collection=${collection} --dir=- --drop"
	${DUMP_BIN} --host=${src_mongo_host} --db=${src_mongo_db} --collection=${collection} --out=- | ${RESTORE_BIN} --host=${dst_mongo_host} --db=${src_mongo_db} --collection=${collection} --dir=- --drop

	# 3.2 create index for featuredb_xxx
	echo "create index:${collection}"
	echo -e "use featuredb\ndb.${collection}.ensureIndex({\"uuid\":1})" | ${MONGO_BIN} ${dst_mongo_host}
done

sleep 2
echo_green "------ backup and restore finished! ------"

###################################################
# 4. kill mongo
echo "killing mongod ..."
pkill -f "mongod"

echo "transfer featuredb finished!"
