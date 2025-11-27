#!/usr/bin/env bash
set -euo pipefail

# Sobe os serviços e aguarda as portas principais ficarem disponíveis.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"
cd "$ROOT_DIR"

echo "Subindo serviços com Docker Compose..."
docker compose up -d --remove-orphans

wait_port() {
  local host=$1
  local port=$2
  local name=$3
  local timeout=${4:-120}
  local start=$(date +%s)
  echo -n "Aguardando ${name} (${host}:${port}) ficar disponível"
  until nc -z "$host" "$port" >/dev/null 2>&1; do
    echo -n "."
    sleep 2
    now=$(date +%s)
    if (( now - start > timeout )); then
      echo
      echo "Tempo esgotado ao aguardar ${name} em ${host}:${port}." >&2
      exit 1
    fi
  done
  echo " OK"
}

echo "Verificando portas..."
wait_port localhost 2181  "Zookeeper"
wait_port localhost 9092  "Kafka"
wait_port localhost 5432  "Postgres"
wait_port localhost 8081  "Druid Coordinator"
wait_port localhost 8090  "Druid Overlord"
wait_port localhost 8082  "Druid Broker"
wait_port localhost 8083  "Druid Historical"
wait_port localhost 8091  "Druid MiddleManager"
wait_port localhost 8888  "Druid Router"
wait_port localhost 8080  "Kafka UI"

echo
echo "Todos os serviços principais estão respondendo nas portas esperadas."
echo "UIs disponíveis:"
echo "  - Kafka UI:   http://localhost:8080"
echo "  - Druid UI:   http://localhost:8888"
echo
echo "Utilitários:"
echo "  - Criar tópico:      ./scripts/create-topic.sh"
echo "  - Enviar eventos:    ./scripts/send-sample.sh"
echo "  - Submeter supervisor Druid: ./scripts/submit-supervisor.sh"
