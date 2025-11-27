#!/usr/bin/env bash
set -euo pipefail

BOOT=${BOOTSTRAP_SERVERS:-kafka:9092}
TOPIC=${TOPIC:-druid-events}
PARTITIONS=${PARTITIONS:-3}
REPLICATION=${REPLICATION:-1}

echo "Creating topic $TOPIC on $BOOT if not exists..."
docker compose exec -T kafka kafka-topics.sh \
  --bootstrap-server $BOOT \
  --create --if-not-exists \
  --topic "$TOPIC" \
  --partitions $PARTITIONS \
  --replication-factor $REPLICATION
echo "Done."
