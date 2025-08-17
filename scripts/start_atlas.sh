#!/bin/bash

set -e

HIVE_HOST=$(echo "$ATLAS_HIVE_METASTORE_URL" | cut -d':' -f1)
HIVE_PORT=$(echo "$ATLAS_HIVE_METASTORE_URL" | cut -d':' -f2)

echo "Waiting for Hive Metastore ($HIVE_HOST:$HIVE_PORT) to be available..."
# Wait until the Hive Metastore container is up and accepting connections.
while ! nc -z "$HIVE_HOST" "$HIVE_PORT"; do
    sleep 2
done
echo "Hive Metastore is available."

echo "Starting Apache Atlas..."
${ATLAS_HOME}/bin/atlas_start.py &
echo "Tailing Apache Atlas logs..."
# Tail the Atlas application log to keep the container running.
tail -fF ${ATLAS_HOME}/logs/application.log

