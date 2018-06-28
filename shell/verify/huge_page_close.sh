#!/bin/bash

INITD_PATH="/etc/init.d/"

cd `dirname $0`
curpath=`pwd`

FILE_NAME="disable-transparent-hugepages.sh"
BOOT_START_FILE="${curpath}/${FILE_NAME}"
CHECK_IDENTITY="${curpath}/init.sh"

function CheckWhoAmI()
{
    ${CHECK_IDENTITY}
    if [ $? -ne 0 ]; then
        return -1
    fi
    return 0
}

# Detects which OS and if it is Linux then it will detect which Linux Distribution.
function GetOSInfo()
{
    OS=`uname -s`
    REV=`uname -r`
    MACH=`uname -m`

    if [ "${OS}" = "SunOS" ] ; then
        OS=Solaris
        ARCH=`uname -p` 
        OSSTR="${OS} ${REV}(${ARCH} `uname -v`)"
    elif [ "${OS}" = "AIX" ] ; then
        OSSTR="${OS} `oslevel` (`oslevel -r`)"
    elif [ "${OS}" = "Linux" ] ; then
        KERNEL=`uname -r`
        if [ -f /etc/redhat-release ] ; then
            DIST='RedHat'
            PSUEDONAME=`cat /etc/redhat-release | sed s/.*\(// | sed s/\)//`
            REV=`cat /etc/redhat-release | sed s/.*release\ // | sed s/\ .*//`
        elif [ -f /etc/SUSE-release ] ; then
            DIST="SUSE `cat /etc/SUSE-release | tr "\n" ' '| sed s/VERSION.*//`"
            REV=`cat /etc/SUSE-release | tr "\n" ' ' | sed s/.*=\ //`
        elif [ -f /etc/mandrake-release ] ; then
            DIST='Mandrake'
            PSUEDONAME=`cat /etc/mandrake-release | sed s/.*\(// | sed s/\)//`
            REV=`cat /etc/mandrake-release | sed s/.*release\ // | sed s/\ .*//`
        elif [ -f /etc/debian_version ] ; then
            DIST="Debian `cat /etc/debian_version`"
            REV=""

        fi
        if [ -f /etc/UnitedLinux-release ] ; then
            DIST="${DIST}[`cat /etc/UnitedLinux-release | tr "\n" ' ' | sed s/VERSION.*//`]"
        fi
        
        OSSTR="${OS} ${DIST} ${REV}(${PSUEDONAME} ${KERNEL} ${MACH})"

    fi

    echo ${OSSTR}
}

# THP stand for 'Transparent Huge Pages'
function RemoveTHPInitScript()
{
    osstr=`GetOSInfo`
    echo "${osstr}"
    OS=`echo "${osstr}" | awk '{print $1}'`
    if [ "AIX" == "{OS}" -o "Solaris" == "${OS}" ]; then
        echo "not support this OS:${OS}"
        return -1
    fi

    DIST=`echo "${osstr}" | awk '{print $2}'`
    ret=0
    case "${DIST}" in
    "RedHat")
        sudo chkconfig --del "${FILE_NAME}"
    ;;
    "SUSE")
        # may be wrong, I don't know
        sudo insserv -r /etc/init.d/"${FILE_NAME}"
    ;;
    "Debian")
        sudo update-rc.d -f "${FILE_NAME}" remove 
    ;; 
    *)
        echo "DIST: ${DIST} not supported" 
        ret=-1
    ;;  
    esac

    echo "del ${FILE_NAME} from ${INITD_PATH}"
    target="${INITD_PATH}/${FILE_NAME}"
    if [ -f "${target}" ]; then
        sudo rm "${target}" 
    fi

    return ${ret};
}

function AddDisableTHPInitScript()
{
    osstr=`GetOSInfo`
    echo "${osstr}"
    OS=`echo "${osstr}" | awk '{print $1}'`
    if [ "AIX" == "{OS}" -o "Solaris" == "${OS}" ]; then
        echo "not support this OS:${OS}"
        return -1
    fi

    echo "cp ${BOOT_START_FILE} to ${INITD_PATH}"
    if [ ! -f "${BOOT_START_FILE}" ]; then
        echo "${BOOT_START_FILE} not exist, the performance of mongodb would not be good."
        return -1
    fi
    chmod +x "${BOOT_START_FILE}"
    sudo cp "${BOOT_START_FILE}" "${INITD_PATH}"
    if [ ! -f "${BOOT_START_FILE}" ]; then
        echo "cp ${BOOT_START_FILE} ${INITD_PATH} fail!"
        return -1
    fi

    DIST=`echo "${osstr}" | awk '{print $2}'`
    ret=0
    case "${DIST}" in
    "RedHat")
        sudo chkconfig --add "${FILE_NAME}"
    ;;
    "SUSE")
        sudo insserv /etc/init.d/"${FILE_NAME}"
    ;;
    "Debian")
        sudo update-rc.d "${FILE_NAME}" defaults 
    ;; 
    *)
        echo "DIST: ${DIST} not supported" 
        ret=-1
    ;;  
    esac
    return ${ret};
}


##################### BEGIN HERE #######################
YourCommand="install"

if [ $# -gt 0 ]; then
    echo $1 
    YourCommand=$1
fi
echo "${YourCommand}"

case "${YourCommand}" in
"install")

    echo "add disable transparent-huge-pages init script"
    AddDisableTHPInitScript
    if [ $? -eq 0 ]; then
        sudo -H -u root bash -c "${BOOT_START_FILE} start" 
    else
        echo "WARNING!! transparent-huge-pages, performance of mongodb may be bad!"
    fi
;;
"uninstall")
    RemoveTHPInitScript
    # TODO. add uninstall.sh
    # uninstall.sh
;;
*)
    echo "unknown command"
;;
esac
