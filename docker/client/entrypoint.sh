#!/bin/sh

USER_ID=${UID}
GROUP_ID=${GID}

echo "Starting Hydrus with UID/GID : $USER_ID/$GROUP_ID"

echo "Patching Hydrus"

cd /opt/hydrus/

if [ -f "/patch.patch" ]; then
  patch -f -p1 -i /patch.patch
fi

#if [ $USER_ID !=  0 ] && [ $GROUP_ID != 0 ]; then
#  find /opt/hydrus/ -not -path "/opt/hydrus/db/*" -exec chown hydrus:hydrus "{}" \;
#fi

stop() {
  pkill supervisord
  sleep 1
}

trap "stop" SIGTERM

supervisord -c /etc/supervisord.conf &
wait $!