#!/usr/bin/env bash

rootfsDir=$1
rc=0

# the rood directory should be with permissions 0700
echo "checking home permissions"
findCommand="usr/bin/find"
homeDir="home"
wrongPermissions="0777"

output=$("${rootfsDir}/${findCommand}" "${rootfsDir}" -name "${homeDir}" -perm "${wrongPermissions}")

if [ -z "${output}" ]
then
      echo "correct home permissions"
else
      echo "wrong home permissions"
      rc=1
fi

exit $rc
