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
  cd /usr/lib/python3.8/site-packages/requests
    echo "Patching Requests"
    patch -f -p2 -i /opt/hydrus/docker/client/requests.patch
  cd /opt/hydrus/
fi

sed -i "/import RFB/a \
  import WebAudio from '../core/webaudio.js';" \
/opt/noVNC/app/ui.js

sed -i "/connectFinished(e)/a \
  var wa = new WebAudio('$NOVNC_AUDIO_ADDRESS'); \
  document.getElementsByTagName('canvas')[0].addEventListener('keydown', e => { wa.start(); });" \
/opt/noVNC/app/ui.js

#if [ $USER_ID !=  0 ] && [ $GROUP_ID != 0 ]; then
#  find /opt/hydrus/ -not -path "/opt/hydrus/db/*" -exec chown hydrus:hydrus "{}" \;
#fi

exec supervisord -c /etc/supervisord.conf
