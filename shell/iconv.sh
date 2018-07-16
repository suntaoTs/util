#!/bin/bash

cd `dirname $0`

function usage() {
    echo $0 path/to/conv/file/or/dir
}

function getcharset(){
    echo `file -i $1 | awk -F "charset=" '{print $2}'`
}

if test $# -ne 1 ; then
    usage
    exit 1
fi

if test -f $1 ; then
    filelist=($1)
else
    filelist=(`tree -fi $1`)
fi

for file in ${filelist[*]} ; do
    if test -f $file ; then
        iconv -f gbk -t utf8 $file 2>/dev/null 1>/dev/null
        if test 0 -ne $? ; then
            echo "$file is not gbk"
            continue
        fi
        
        iconv -f gbk -t utf8 $file -o .temp_32urh23bj
        if test 0 -ne $? ; then
            echo "convert failed: $file"
        else
            mv .temp_32urh23bj $file
            echo "convert ok: $file"
        fi
    fi
done
