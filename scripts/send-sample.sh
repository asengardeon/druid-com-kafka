#!/usr/bin/env bash
set -euo pipefail

TOPIC=${TOPIC:-druid-events}
BOOT=${BOOTSTRAP_SERVERS:-kafka:9092}
COUNT=${COUNT:-20}

cat > /tmp/sample-events.jsonl <<'EOF'
{"ts":"2024-01-01T00:00:01Z","user":"alice","action":"click","value":1}
{"ts":"2024-01-01T00:00:02Z","user":"bob","action":"view","value":2}
{"ts":"2024-01-01T00:00:03Z","user":"carol","action":"buy","value":3}
EOF

# Duplicate lines to reach COUNT
lines=$(wc -l < /tmp/sample-events.jsonl)
if [ "$COUNT" -gt "$lines" ]; then
  extra=$((COUNT - lines))
  i=0
  while [ $i -lt $extra ]; do
    # Cycle users/actions with current second as time
    ts=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    case $((i % 3)) in
      0) user=alice; action=click; val=$(( (i%5)+1 ));;
      1) user=bob; action=view; val=$(( (i%5)+2 ));;
      *) user=carol; action=buy; val=$(( (i%5)+3 ));;
    esac
    echo "{\"ts\":\"$ts\",\"user\":\"$user\",\"action\":\"$action\",\"value\":$val}" >> /tmp/sample-events.jsonl
    i=$((i+1))
  done
fi

echo "Enviando $COUNT eventos para Kafka ($BOOT / $TOPIC) via ubuntu-tools..."
docker compose exec -T ubuntu-tools bash -lc '
  set -euo pipefail
  cmd="$(command -v kcat || true)"; [ -z "$cmd" ] && cmd="$(command -v kafkacat || true)";
  if [ -z "$cmd" ]; then echo "kcat/kafkacat não encontrado"; exit 1; fi
  $cmd -P -b '"$BOOT"' -t '"$TOPIC"'
' < /tmp/sample-events.jsonl
echo "OK."
