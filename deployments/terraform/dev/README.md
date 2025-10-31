# Terraform Dev Topics

Модуль Terraform поднимает dev-темы Kafka для чат-сервисов и синхронизирует их конфигурацию с локальным брокером из `docker-compose`.

## Требования
- Terraform версии не ниже 1.5.
- Локально запущенный Kafka (`localhost:9092`) из корневого `docker-compose.yaml`.

## Ключевые переменные
- `kafka_bootstrap_servers` — список bootstrap-серверов (по умолчанию `["localhost:9092"]`).
- `topic_definitions` — карта с описанием тем. Ключ — имя топика, значение — объект с полями:
  - `partitions` — требуемое число партиций;
  - `retention_days` — окно хранения в сутках (конвертируется в `retention.ms`);
  - `cleanup_policy` — необязательная замена глобальному `topic_cleanup_policy`;
  - `extra_config` — произвольные дополнительные настройки для конкретной темы.
- Остальные переменные наследуются от базовой конфигурации (`replication_factor`, `topic_min_insync_replicas`, `extra_topic_config` и т. д.).

По умолчанию описаны два топика с валидацией диапазонов:
- `chat.presence.events`: 3–6 партиций, хранение 1–7 дней (стартовое значение 3/1).
- `chat.message.events`: 6–12 партиций, хранение 7–30 дней (стартовое значение 6/7).

Terraform не позволит применить значения вне допустимых границ — сработает `validation` внутри `variables.tf`.

## Запуск
```bash
cd deployments/terraform/dev
terraform init          # однократно
terraform plan          # проверяем дельту
terraform apply         # создаём/обновляем темы
```

При необходимости заведите `terraform.tfvars` или передайте переменные через `-var`, например:
```hcl
topic_definitions = {
  "chat.message.events" = {
    partitions     = 8
    retention_days = 14
  }
  "chat.message.events.dlq" = {
    partitions     = 6
    retention_days = 14
    cleanup_policy = "delete"
  }
}
```

## Подсказки
- Глобальные настройки (`topic_cleanup_policy`, `extra_topic_config`) применяются ко всем темам, а затем переопределяются конкретными значениями из `topic_definitions`.
- Конфигурация была рассчитана на одноброкерный стенд, поэтому `replication_factor` по умолчанию равен 1. Для кластера отредактируйте это значение через переменные.
- Файл состояния `terraform.tfstate` остаётся локально и не коммитится — добавлен в `.gitignore`.
