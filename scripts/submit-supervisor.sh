#!/usr/bin/env bash
set -euo pipefail

OVERLORD=${OVERLORD:-http://localhost:8090}
SPEC_PATH=${1:-specs/kafka-supervisor.json}

if [ ! -f "$SPEC_PATH" ]; then
  echo "Spec não encontrado: $SPEC_PATH" >&2
  exit 1
fi

echo "Submetendo supervisor para $OVERLORD ..."
curl -sS -X POST -H 'Content-Type: application/json' \
  --data-binary @"$SPEC_PATH" \
  "$OVERLORD/druid/indexer/v1/supervisor" | jq .

echo "Listando supervisors ativos:"
curl -sS "$OVERLORD/druid/indexer/v1/supervisor" | jq .
