#!/bin/bash


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
. git_util.sh

BRANCH=$1

if [[ $# == 0 ]]; then
  echo "invalid param: no branch name"
  exit 1
fi

exit_on_err "git checkout ${BRANCH}"
exit_on_err "git submodule foreach 'git reset --hard'"
exit_on_err "git submodule foreach 'git checkout ${BRANCH}'"
detached=`git_is_head_detached`
if [[ a"no" == a"${detached}" ]] ; then
    exit_on_err "git submodule foreach 'git pull'"
fi



