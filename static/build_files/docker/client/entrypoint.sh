#!/bin/sh

USER_ID=${UID:-1000}
GROUP_ID=${GID:-1000}

PYTHON_MAJOR_VERSION=$(python3 -c "import sys; print(sys.version_info.major)")
PYTHON_MINOR_VERSION=$(python3 -c "import sys; print(sys.version_info.minor)")

#apk add xterm
echo "Starting Hydrus with UID/GID : $USER_ID/$GROUP_ID"
groupmod --gid "$GROUP_ID" hydrus
usermod --uid "$USER_ID" --gid "$GROUP_ID" hydrus
echo "Running as: $(id)"

if [ $USER_ID !=  1000 ] && [ $GROUP_ID != 1000 ]; then
  echo "Modifying /opt/hydrus permissions, excluding /opt/hydrus/db/*"
  find /opt/hydrus/ -path "/opt/hydrus/db/*" -prune -o -exec chown hydrus:hydrus "{}" \;
fi

cd /opt/hydrus/

if [ -f "/opt/hydrus/static/build_files/docker/client/patch.patch" ]; then
  echo "Patching Hydrus"
  patch -f -p1 -i /opt/hydrus/static/build_files/docker/client/patch.patch
fi

# Determine which requests patch file to use and warn on unsupported python version
if [ "$PYTHON_MAJOR_VERSION" == "3" ]; then
  if [ "$PYTHON_MINOR_VERSION" -lt 11 ]; then
    PATCH_FILE="/opt/hydrus/static/build_files/docker/client/requests.patch"
    if [ -f "$PATCH_FILE" ]; then
      echo "Found and apply requests patch for py 3.10 and below"
      cd $(python3 -c "import sys; import requests; print(requests.__path__[0])")
      patch -f -p2 -i "$PATCH_FILE"
    fi
  elif [ "$PYTHON_MINOR_VERSION" -eq 11 ]; then
    PATCH_FILE="/opt/hydrus/static/build_files/docker/client/requests.311.patch"
    if [ -f "$PATCH_FILE" ]; then
      echo "Found and apply requests patch for py 3.11"
      cd $(python3 -c "import sys; import requests; print(requests.__path__[0])")
      patch -f -i "$PATCH_FILE"
    fi
  elif [ "$PYTHON_MINOR_VERSION" -eq 12 ]; then
    PATCH_FILE="/opt/hydrus/static/build_files/docker/client/requests.311.patch"
    if [ -f "$PATCH_FILE" ]; then
      echo "Found and apply requests patch for py 3.12"
      cd $(python3 -c "import sys; import requests; print(requests.__path__[0])")
      patch -f -i "$PATCH_FILE"
    fi
  else
    echo "Unsupported Python minor version: $PYTHON_MINOR_VERSION"
  fi
else
  echo "Unsupported Python major version: $PYTHON_MAJOR_VERSION"
fi
cd /opt/hydrus/

exec supervisord -c /etc/supervisord.conf
