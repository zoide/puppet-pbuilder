#!/usr/bin/env bash
# $Id: run_pbuilder.sh 4765 2011-11-02 12:47:26Z uwaechte $

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