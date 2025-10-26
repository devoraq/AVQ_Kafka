# Dev Kafka Topic Terraform

This configuration provisions the development Kafka topic for the realtime gateway.

## Prerequisites

- Terraform ≥ 1.5
- Kafka broker from `docker-compose.yaml` running locally (`localhost:9092`)

## Usage

```bash
cd deployments/terraform/dev
terraform init
terraform apply
```

Important variables already match the Compose stack:

- `kafka_bootstrap_servers` → `["localhost:9092"]`
- `topic_names` → `["test-topic"]`
- `topic_partitions` → `3`
- `replication_factor` → `1`

To provision multiple topics, extend `topic_names`, e.g.:

```hcl
topic_names = [
  "payments-events",
  "payments-dead-letter",
  "payments-metrics",
]
```

Override any variable via `-var` or a `terraform.tfvars` file if needed.
