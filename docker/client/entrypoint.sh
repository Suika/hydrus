#!/bin/sh

USER_ID=${UID}
GROUP_ID=${GID}

echo "Starting Hydrus with UID/GID : $USER_ID/$GROUP_ID"

cd /opt/hydrus/

if [ -f "/opt/hydrus/docker/client/patch.patch" ]; then
  echo "Patching Hydrus"
  patch -f -p1 -i /opt/hydrus/docker/client/patch.patch
fi

if [ -f "/opt/hydrus/docker/client/requests.patch" ]; then
  pushd /usr/lib/python3.7/site-packages/requests
    echo "Patching Requests"
    patch -f -p1 -i /opt/hydrus/docker/client/requests.patch
  popd
fi

#if [ $USER_ID !=  0 ] && [ $GROUP_ID != 0 ]; then
#  find /opt/hydrus/ -not -path "/opt/hydrus/db/*" -exec chown hydrus:hydrus "{}" \;
#fi

exec supervisord -c /etc/supervisord.conf