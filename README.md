# Kafka Stack

Локальный стенд Kafka с минимальными зависимостями для разработки и тестирования интеграций. Репозиторий объединяет Docker Compose, конфигурацию брокера, Terraform-инфраструктуру и вспомогательные скрипты.

## Структура репозитория

- `docker-compose.yaml` — одновременный запуск Kafka (режим KRaft, образ `apache/kafka:4.0.1`) и Confluent Schema Registry.
- `config/` — примерные переменные окружения и конфиги запуска (`config/kafka.env` и др.).
- `deployments/terraform/` — Terraform-код, управляющий dev-темами.
- `scripts/` — утилиты для установки Terraform и работы с топиками.
- `docs/` — подробные заметки по параметрам кластера и best practices (`docs/cluster.md`).

## Требования

- Docker и Docker Compose v2.
- Terraform версии не ниже 1.5 (для Terraform-кода в `deployments/terraform/dev`).
- Свободные порты `9092` (Kafka) и `8081` (Schema Registry) на локальной машине.

## Быстрый старт

```bash
docker compose up -d          # запускаем Kafka и Schema Registry
scripts/install_terraform.sh  # устанавливаем Terraform (один раз)
```

### Проверка состояния

```bash
docker compose ps                 # список контейнеров
docker logs kafka --tail 20       # последние строки лога брокера
docker exec kafka /opt/kafka/bin/kafka-topics.sh \
  --bootstrap-server localhost:9092 --list
```

## Управление темами

- Вручную: используйте `kafka-topics.sh` внутри контейнера, например:
  ```bash
  docker exec -it kafka /opt/kafka/bin/kafka-topics.sh \
    --bootstrap-server localhost:9092 \
    --create \
    --topic demo \
    --partitions 3 \
    --replication-factor 1
  ```
- Инфраструктурно: в `deployments/terraform/dev` описана карта `topic_definitions`. Каждая запись задаёт количество партиций и окно хранения; при выполнении `terraform apply` темы создаются или обновляются автоматически.

```bash
cd deployments/terraform/dev
terraform init
terraform plan   # проверяем изменения
terraform apply
```

По умолчанию настроены темы:

- `chat.presence.events` — 3 партиции, хранение 1 день (разрешён диапазон 3–6 партиций и 1–7 дней).
- `chat.message.events` — 6 партиций, хранение 7 дней (разрешён диапазон 6–12 партиций и 7–30 дней).
- `chat.message.acks` - 6 партиций, хранение 7 дней (разрешён диапазон 6–12 партиций и 7–30 дней).

## Остановка и очистка

```bash
docker compose down         # остановка контейнеров
docker compose down -v      # плюс удаление volume `kafka-data`
```

## Дополнительные материалы

- Подробный чек-лист параметров брокера и клиентов: `docs/cluster.md`.
- Переменные окружения для локальной разработки: файл `config/kafka.env`.
