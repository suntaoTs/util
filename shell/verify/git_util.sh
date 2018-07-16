#!/bin/bash

# @param module optional
function git_head_branch() {
    local module=$1
    if [[ -z "${module}" ]]; then
        cat .git/HEAD | awk -F 'refs/heads/' '{print $2}'
    else
        cat .git/modules/${module}/HEAD | awk -F 'refs/heads/' '{print $2}'
    fi
}

# @param module optional
function git_is_head_detached() {
    local branch=`git_head_branch $1`
    if [[ -z "${branch}" ]]; then
        echo "yes"
    else
        echo "no"
    fi
}

# @param module optional
function git_head_version_tag() {
    local module=$1
#    local decorates=(`
#        if [[ -z "${module}" ]]; then
#            git log --oneline  -1 --decorate=full | grep "(.*)" -o
#        else
#            cd ${module}
#            git log --oneline  -1 --decorate=full | grep "(.*)" -o
#        fi
#    `)
#
#    local versions=(`
#        for ((i=0; i < ${#decorates[*]}; i++)); do
#            echo ${decorates[$i]} | grep -P "refs/tags/[a-zA-Z]*\d+\.\d+\.\d+" | awk -F 'refs/tags/|,' '{print $2}'
#        done
#    `)
#
#    if [[ ! -z "${versions[*]}" ]] ; then
#        echo ${versions[0]}
#    fi
    local version=`LC_ALL=C git branch | awk -F ' ' '{print $4}'`
    echo "${version%\)}"
}

# detached=`git_is_head_detached`
# 
# if [[ "yes" == "${detached}" ]] ; then
#     echo "head version is: `git_head_version_tag`"
# else
#     echo "head branch is: `git_head_branch`"
# fi
# 
# echo "submodule infos:"
# 
# SUBMODULES=(`git submodule status | awk -F ' ' '{print $2}'`)
# 
# for module in ${SUBMODULES[*]} ; do
#     
#     detached=`git_is_head_detached ${module}`
#     
#     if [[ "yes" == "${detached}" ]]; then
#         echo "module ${module} head version is: `git_head_version_tag ${module}`"
#     else
#         echo "module ${module} head branch is: `git_head_branch ${module}`"
#     fi
# done


