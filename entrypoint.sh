#!/bin/sh
set -eu
# Keep the existing NAS application; seed only an empty data directory.
if [ ! -e /data/awtrix.jar ]; then
    cp /opt/awtrix/awtrix.jar /data/awtrix.jar
fi
if [ ! -s /data/awtrix.jar ]; then
    echo "ERROR: /data/awtrix.jar is empty; restore a known good JAR from backup." >&2
    exit 1
fi
exec java -jar /data/awtrix.jar
