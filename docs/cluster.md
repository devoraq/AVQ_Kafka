# Настройки dev-кластера Kafka

## Конфигурация брокера
- Используется Apache Kafka 4.0.1 (образ `apache/kafka`) в режиме KRaft с ролями `process.roles=broker,controller` и `node.id=1` — типичный минимальный стенд.
- Слушатели: `PLAINTEXT_INTERNAL://:19092` для взаимодействия контейнеров, `PLAINTEXT_EXTERNAL://:9092` для хост-машины, административный канал — `:9093`.
- Репликация отключена: `default.replication.factor=1`, `min.insync.replicas=1`, нечистые выборы лидера (unclean leader election) заблокированы.
- Retention по умолчанию — 1 день (`log.retention.ms=86400000`), максимальный размер сообщения — 10 МБ (`message.max.bytes=10485760`).
- ACL управляются `StandardAuthorizer`; предусмотрен суперпользователь `admin` и анонимный доступ `ANONYMOUS`. Для продакшен-профиля стоит включить строгую авторизацию.

## Schema Registry
- Confluent Schema Registry 7.6.1 запускается вместе с брокером.
- Режим совместимости рекомендуется выставлять такой же, как в продакшене (например, `BACKWARD`), чтобы ловить нарушения схем заранее.

## Рекомендации для продюсеров
```properties
enable.idempotence=true
acks=all
retries=Integer.MAX_VALUE
delivery.timeout.ms=120000
compression.type=zstd
linger.ms=5
batch.size=32768
```
`max.in.flight.requests.per.connection=1` отключает повторную отправку в параллель — полезно для строгого порядка, но может снижать throughput.

## Рекомендации для консюмеров
```properties
enable.auto.commit=false
isolation.level=read_committed
max.poll.records=200
partition.assignment.strategy=org.apache.kafka.clients.consumer.CooperativeStickyAssignor
```
Коммиты делайте синхронно (`commitSync`) после обработки батча. Пара стратегий `<sticky, cooperative>` снижает ребалансировку, когда консюмеры перезапускаются.

## Dead Letter Queue
- Для критичных потоков используйте пары тематических очередей `<topic>` и `<topic>.dlq`. Скрипт `scripts/create-topic-with-dlq.sh <topic>` создаёт обе с `cleanup.policy=delete` и `retention.ms=172800000` (2 суток).
- Количество партиций и фактор репликации выбирайте под нагрузку потребителей. Не забывайте переносить настройки retention из основной очереди, если нужен больший горизонт анализа.

## Подключение клиентов
- Контейнеры Docker стучатся в `kafka:19092` (внутренний Bootstrap). При конфигурации сервисов в Compose используйте именно его.
- Локальные приложения и инструменты пользуются `localhost:9092`. Если есть корпоративный firewall или особые DNS-настройки, убедитесь, что `localhost` не переопределён.
