#!/bin/bash

cd `dirname $0`

. comm.sh
. git_util.sh

function usage() {
    echo "usage: $0 [-h|--help] [-t|--tag yes|no] [-v|--version <version>] [-m|--model <model>]"
    echo "  -h|--help   Print this menu."
    echo "  -t|--tag    yes|no"
    echo "              Whether Auto create version tag (default no) for this repository and all submodules. Tag value is version."
    echo "  -v|--version <version>"
    echo "              Package version, i.e. 1.3.2_alpha.1, default is current timestamp."
    echo "  -o|--os ubuntu|centos|centos6 "
    echo "              OS name, default is ubuntu."
    echo "  -m|--model <version>"
    echo "              Model version, default is 24001. Current support versions: 24001, 24101"
}

#######################################################################
# get parameters from enviroment

[[ -z "${AUTO_CREATE_TAG}" ]] && AUTO_CREATE_TAG="no"
[[ -z "${VERIFY_SERVER_VERSION}" ]] && VERIFY_SERVER_VERSION=`date '+%F-%H%M%S'`
[[ -z "${MODEL}" ]] && MODEL="24201"

# get parameters from command line
ARGS=`getopt -o ht:v:o:m: -l "help,tag:,version:,model:" -- "$@"`
eval set -- "${ARGS}"

while true;
do
    case "$1" in
        -h|--help)
            usage
            exit 0
            shift
            ;;
        -t|--tag)
            AUTO_CREATE_TAG=$2
            shift 2
            ;;
        -v|--version)
            VERIFY_SERVER_VERSION=$2
            shift 2
            ;;
        -m|--model)
            MODEL=$2
            shift 2
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "invalid option $1"
            exit 1
            ;;
    esac
done

# compose parameters

NOW=`date "+%F %H:%M:%S"`
GITSHA1=`git log -1 --format=%h`
BRANCH="`git_head_branch`"
MODEL_FILE_NAME="M_onlyVerify_int8_${MODEL:0:3}_$((${MODEL:3:2})).0.model"
PACKAGE_NAME="verify_server-${VERIFY_SERVER_VERSION}-${MODEL:0:3}v$((${MODEL:3:2}))-${GITSHA1}"
SDK_FEATURE_VERSION=`ls lib/libsdk_feature.so* | tail -n 1 | awk -F 'libsdk_feature.so.' '{print $2}'`


# print paremeters info

echo_blue "# paremeters: ----------------------------------------------------------"
echo_green " timestamp: ${NOW}"
echo_green " git sha1: ${GITSHA1}"
[[ ! -z ${BRANCH} ]] && echo_green " git branch: ${BRANCH}"
echo_green " model: ${MODEL}"
echo_green " sdk: ${SDK_FEATURE_VERSION}"
echo_green " verify_server: ${VERIFY_SERVER_VERSION}"
echo_green " auto create version tag: ${AUTO_CREATE_TAG}"
echo_green " package name: ${PACKAGE_NAME}"

#######################################################################
# build and packing

echo_blue "# building and packing: -------------------------------------------------"

VERIFY_SERVER_SOURCE_DIR="$PWD"
RELEASE_PATH="${VERIFY_SERVER_SOURCE_DIR}/release/verify_server"

echo_green " source path: ${VERIFY_SERVER_SOURCE_DIR}"
echo_green " release path: ${RELEASE_PATH}"

exit_on_err "rm -rf ${RELEASE_PATH}"
exit_on_err "mkdir -p build && cd build && cmake -D CMAKE_INSTALL_PREFIX=${RELEASE_PATH} .. && make install"

exit_on_err "cd ${RELEASE_PATH}"

exit_on_err "sed -i 's/sdk.extractModel=.*/sdk.extractModel= ..\/models\/verify\/${MODEL_FILE_NAME}/g' featureExtractionWorker/server.properties"
exit_on_err "sed -i 's/FEATURE_MODEL=.*/FEATURE_MODEL=models\/verify\/${MODEL_FILE_NAME}/g' batchInsert/conf4pkg.sh"

echo_green " copy lib "

exit_on_err "mkdir -p native"
exit_on_err "cp -rPl ${VERIFY_SERVER_SOURCE_DIR}/dependency/3rdlib/*.so* native/"
exit_on_err "cp -rP ${VERIFY_SERVER_SOURCE_DIR}/lib/*so* native/"
exit_on_err "strip native/libsdk_feature.so"
exit_on_err "strip native/libsenseface.so"

echo_green " copy models "
exit_on_err "cp -rl ${VERIFY_SERVER_SOURCE_DIR}/models ."
exit_on_err "rm models/verify/*"
exit_on_err "cp -rl ${VERIFY_SERVER_SOURCE_DIR}/models/verify/${MODEL_FILE_NAME} models/verify/"

echo_green " copy python "
exit_on_err "cp -rPl ${VERIFY_SERVER_SOURCE_DIR}/dependency/python/py3.6 ."

echo_green " copy else files"
exit_on_err "cp -r ${VERIFY_SERVER_SOURCE_DIR}/3rdparty ."
exit_on_err "cp -r ${VERIFY_SERVER_SOURCE_DIR}/sysload ."
exit_on_err "cp -r ${VERIFY_SERVER_SOURCE_DIR}/msgcache ."
exit_on_err "cp -r ${VERIFY_SERVER_SOURCE_DIR}/download_tool ."
exit_on_err "cp -r ${VERIFY_SERVER_SOURCE_DIR}/gen_licence_file ."
#exit_on_err "cp -r ${VERIFY_SERVER_SOURCE_DIR}/changelog ."
exit_on_err "cp -r ${VERIFY_SERVER_SOURCE_DIR}/*.sh ."
exit_on_err "cp -r ${VERIFY_SERVER_SOURCE_DIR}/VS.conf ."
exit_on_err "cp -r ${VERIFY_SERVER_SOURCE_DIR}/nginx.verify.conf ."
exit_on_err "cp -r ${VERIFY_SERVER_SOURCE_DIR}/push_gateway_config ."
exit_on_err "cp -r ${VERIFY_SERVER_SOURCE_DIR}/hasptools ."
exit_on_err "rm release.sh"
exit_on_err "rm git_util.sh"
exit_on_err "rm get_branch.sh"
exit_on_err "rm gen_licence_file/key/verify_server.key"
exit_on_err "rm gen_licence_file/bin/StLicensePriv"
exit_on_err "rm gen_licence_file/decode_licence_file.sh"

exit_on_err "mkdir -p log"
exit_on_err "chmod -R 750 *"

# create version file
echo_green " merge version files "
exit_on_err "echo verify server ${VERIFY_SERVER_VERSION} >> version"
[[ ! -z ${BRANCH} ]] && exit_on_err "echo git branch ${BRANCH} >> version"
exit_on_err "echo git sha1 ${GITSHA1} >> version"
exit_on_err "echo sdk ${SDK_FEATURE_VERSION} >> version"
exit_on_err "echo model ${MODEL:0:3}v$((${MODEL:3:2})) >> version" 
exit_on_err "echo -- >> version"
exit_on_err "echo verify server algo >> version"
exit_on_err "cat featureExtractionMaster/version >> version"
exit_on_err "echo -- >> version"
exit_on_err "echo verify server search >> version"
exit_on_err "cat db_server/version >> version"
exit_on_err "echo -- >> version"
exit_on_err "echo verify server http >> version"
exit_on_err "cat verify_server_http/version >> version"
exit_on_err "echo -- >> version"
exit_on_err "echo batch insert tool >> version"
exit_on_err "cat batchInsert/version >> version"

# gen module.info
echo_green " gen module.info "
exit_on_err "echo verifyServer,10,静态比对服务器,${VERIFY_SERVER_VERSION}, >> module.info"
exit_on_err "VERIFY_SERVER_HTTP=`cat verify_server_http/version | cut -d ' ' -f 2`"
exit_on_err "echo verifyServer:http,10,接口,${VERIFY_SERVER_HTTP}, >> module.info"
exit_on_err "VERIFY_SERVER_MASTER=`cat featureExtractionMaster/version |grep master |cut -d ' ' -f 2`"
exit_on_err "echo verifyServer:algo_engine_master,10,算法引擎master,${VERIFY_SERVER_MASTER}, >> module.info"
exit_on_err "VERIFY_SERVER_WORKER=`cat featureExtractionMaster/version |grep worker |cut -d ' ' -f 2`"
exit_on_err "echo verifyServer:algo_engine_worker,10,算法引擎worker,${VERIFY_SERVER_WORKER}, >> module.info"
exit_on_err "VERIFY_SERVER_SEARCH=`cat db_server/version|grep server|cut -d ' ' -f 2`"
exit_on_err "echo verifyServer:search_engine,10,搜索引擎,${VERIFY_SERVER_SEARCH}, >> module.info"

# create .gitlog
echo_green " create .gitlog "
exit_on_err "echo -e '-----------------------------------------------------------------------\nverify_server:' >> .gitlog"
exit_on_err "git log --pretty=format:\"%cn committed %h on %cd\" -3 >> .gitlog"
exit_on_err "echo -e '\n-----------------------------------------------------------------------\n' >> .gitlog"

#######################################################################
# compressing

echo_green " compressing "
exit_on_err "cd .."
exit_on_err "tar -czvf ${PACKAGE_NAME}.tgz verify_server"
exit_on_err "md5sum ${PACKAGE_NAME}.tgz > ${PACKAGE_NAME}.md5"
exit_on_err "rm -rf verify_server" 
 
####################################################################### 
# create tags 
 
if [[ "yes" == "${AUTO_CREATE_TAG}" ]]; then 
    echo_blue "# create tags: --------------------------------------------------------" 
    exit_on_err "git tag -a ${VERIFY_SERVER_VERSION} -m '${NOW} package ${PACKAGE_NAME}'" 
    exit_on_err "git push origin ${VERIFY_SERVER_VERSION}" 
    # exit_on_err "git submodule foreach -q 'git tag -a ${VERIFY_SERVER_VERSION} -m \"${NOW} package ${PACKAGE_NAME}\"'" 
    # exit_on_err "git submodule foreach -q 'git push origin ${VERIFY_SERVER_VERSION}'" 
fi 

#######################################################################
# finished

echo_yellow "\n$0 finished\n"
