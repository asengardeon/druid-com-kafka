Projeto: Druid com Kafka (via Docker Compose)

Este repositório fornece um ambiente completo para ingestão de dados do Kafka no Apache Druid usando Docker Compose. Inclui UIs do Kafka e do Druid e scripts para automatizar a operação.

Como usar (passo a passo rápido)
1) Subir os serviços e aguardar readiness:
   - ./scripts/up.sh

2) Criar o tópico Kafka (opcional):
   - ./scripts/create-topic.sh

3) Enviar eventos de exemplo para o Kafka:
   - ./scripts/send-sample.sh

4) Submeter o supervisor de ingestão do Druid:
   - ./scripts/submit-supervisor.sh

5) Acessar as UIs:
   - Kafka UI: http://localhost:8080
   - Druid UI: http://localhost:8888 (SQL: SELECT __time, "user", action, value FROM events ORDER BY __time DESC LIMIT 10;)

Pré-requisitos
- Docker e Docker Compose instalados
- Portas livres: 2181, 5432, 8080, 8081, 8082, 8083, 8090, 8091, 8888, 9092
- Permissão de execução para os scripts (se necessário: chmod +x scripts/*.sh)

Serviços principais
- Zookeeper: ubuntu/zookeeper:latest (2181)
- Kafka: ubuntu/kafka:latest (9092)
- Postgres (metadados): postgres:14 (5432)
- Druid (apache/druid:27.0.0): Coordinator (8081), Overlord (8090), Broker (8082), Historical (8083), MiddleManager (8091), Router (8888)
- Kafka UI: provectuslabs/kafka-ui:latest (8080)
- Ubuntu Tools (utilitários): ubuntu:22.04 com kcat/kafkacat, curl, jq

Scripts e variáveis úteis
- scripts/up.sh: sobe e aguarda portas
- scripts/create-topic.sh: cria tópico se não existir
  - Variáveis: TOPIC (druid-events), PARTITIONS (3), REPLICATION (1), BOOTSTRAP_SERVERS (kafka:9092)
- scripts/send-sample.sh: envia eventos JSONLines de exemplo
  - Variáveis: TOPIC (druid-events), BOOTSTRAP_SERVERS (kafka:9092), COUNT (20)
- scripts/submit-supervisor.sh: envia spec do supervisor para o Overlord
  - Variáveis: OVERLORD (http://localhost:8090), SPEC_PATH (specs/kafka-supervisor.json)

Personalização
- Ajuste a spec de ingestão em specs/kafka-supervisor.json (datasource, timestampSpec, dimensions, tópico)
- Ajuste configurações do Druid em druid/conf/druid/_common/common.runtime.properties (ZK, Postgres, extensões)
- Edite docker-compose.yml para alterar portas e volumes

Solução de problemas
- Porta ocupada: altere as portas no docker-compose.yml ou libere no host
- Clientes no host não conectam ao Kafka: o compose anuncia kafka:9092 para a rede Docker; para clientes no host, use os scripts (via containers) ou ajuste advertised listeners para localhost
- Supervisor sem tarefas/dados: verifique se há mensagens no tópico e veja logs do Overlord/MiddleManager
- Kafka UI sem cluster: valide BOOTSTRAPSERVERS=kafka:9092 e ZOOKEEPER=zk:2181 no serviço kafka-ui

Aviso
Ambiente destinado a desenvolvimento/local (não produção).