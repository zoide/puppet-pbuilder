#!/usr/bin/env bash

DSC=$1
export ARCH=$2
export DIST=$3
echo "##############################################################"
echo "ARCH=$2 DIST=$3 /usr/sbin/pbuilder --build ${DSC}"
echo "##############################################################"
/usr/sbin/pbuilder --build ${DSC}
ERR=$?
if [[ $ERR -ne 0 ]]; then
    echo "ERROR: pbuilder exit ${ERR}"
    exit $ERR
fi
echo "======> RUNNER END <=============="
