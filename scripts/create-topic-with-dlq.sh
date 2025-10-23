#!/usr/bin/env bash

# Create a topic and its <topic>.dlq companion with dev retention defaults.
# Usage: ./scripts/create-topic-with-dlq.sh orders [broker-host:port]

set -euo pipefail

if [[ $# -lt 1 || $# -gt 2 ]]; then
  echo "Usage: $0 <topic-name> [bootstrap-server]" >&2
  exit 1
fi

TOPIC="$1"
BOOTSTRAP_SERVER="${2:-kafka:19092}"
PARTITIONS="${PARTITIONS:-1}"

create_topic() {
  local name="$1"
  kafka-topics.sh \
    --bootstrap-server "$BOOTSTRAP_SERVER" \
    --create \
    --topic "$name" \
    --partitions "$PARTITIONS" \
    --replication-factor 1 \
    --config cleanup.policy=delete \
    --config retention.ms=172800000 \
    --if-not-exists
}

create_topic "$TOPIC"
create_topic "${TOPIC}.dlq"
