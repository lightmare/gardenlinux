#!/usr/bin/env bash

rootfsDir=$1

echo "testing for needed capabilities"
absPath=$(readlink -f $(dirname "${BASH_SOURCE[0]}"))
rootfsDir=$(readlink -f "$rootfsDir")

source "${absPath}/"helpers
if ! check_rootdir "${rootfsDir}"; then
	exit 1
fi

cap_files="${absPath}/cap_files"
capFiles=$(find ${rootfsDir} -type f -exec getcap {} \; 2> /dev/null | awk -v p=${rootfsDir%/} '{ gsub(p, "", $1); print;}' | sort) 
capFilesDefined=$(sort ${cap_files})

if diff <(echo "$capFiles") <(echo "$capFilesDefined") > /dev/null; then
	echo "OK - all capabilities as expected"
else
	echo "FAIL - capabilities don't match"
	echo "       expected: $(echo ${capFilesDefined})"
	echo "       got     : $(echo ${capFiles})"
	rc=1
fi

exit $rc
