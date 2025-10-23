# Kafka Stack

Локальная инфраструктура Kafka собрана в отдельном модуле, чтобы сервисы проекта подключались к единому брокеру и схеме Terraform/DevOps.

## Состав директории

- `docker-compose.yaml` — стек из одноброкерной Kafka (режим KRaft, `apache/kafka:4.0.1`) и Confluent Schema Registry.
- `config/` — переменные окружения для брокера (см. `config/kafka.env`).
- `deployments/terraform/` — Terraform-конфигурация для создания dev-тем.
- `scripts/` — утилиты для установки Terraform и управления топиками.
- `docs/` — справочные материалы и best practices (`docs/cluster.md`).

## Требования

- Docker & Docker Compose (v2).
- Terraform ≥ 1.5 (ставится автоматически скриптом).
- Порты `9092` (Kafka) и `8081` (Schema Registry) не должны быть заняты.

## Быстрый старт

```bash
cd kafka
docker compose up -d                # поднимает брокер и schema registry
scripts/install_terraform.sh        # при необходимости ставит Terraform и применяет dev-конфиг
scripts/create-topic-with-dlq.sh orders   # создаёт тему orders и её DLQ
```

### Проверка

```bash
docker compose ps                   # статус контейнеров
docker logs kafka --tail 20         # убедиться, что брокер запустился
docker exec kafka /opt/kafka/bin/kafka-topics.sh \
  --bootstrap-server localhost:9092 --list
```

## Управление топиками

- `scripts/create-topic-with-dlq.sh <topic> [bootstrap]` — создаёт тему и `<topic>.dlq` с dev-конфигом.
- В Terraform (`deployments/terraform/dev`) можно описать нужный набор тем и применить `terraform apply`.

## Остановка и очистка

```bash
docker compose down                 # остановить сервисы
docker compose down -v              # дополнительно удалить volume kafka-data
```

## Дополнительно

- Подробные настройки брокера и рекомендации для продюсеров/консьюмеров описаны в `docs/cluster.md`.
- Переменные окружения можно менять через `.env` или правкой `config/kafka.env`.
