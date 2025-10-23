# Руководство по dev-кластеру Kafka

## Настройка брокера
- Один брокер Apache Kafka 4.0.1 (официальный образ `apache/kafka`) в комбинированном режиме KRaft (`process.roles=broker,controller`, `node.id=1`) — минимальная стоимость.
- Два слушателя: внутренний `PLAINTEXT_INTERNAL://:19092` для docker-сетей и внешний `PLAINTEXT_EXTERNAL://:9092` для хоста; контроллер остаётся на `:9093`.
- Надёжность под одиночный узел: `default.replication.factor=1`, `min.insync.replicas=1`, авто‑создание тем отключено, unclean leader election запрещён.
- Retention 1 день (`log.retention.ms=86400000`), максимальный размер сообщения 10 МиБ (`message.max.bytes=10485760`).
- ACL включены через `StandardAuthorizer`; супер‑пользователи: `admin` и технический `ANONYMOUS`. ACL на темы/группы добавляйте при подключении сервисов.

## Schema Registry
- Confluent Schema Registry 7.6.1 подключён к dev-брокеру.
- Режим совместимости держите таким же, как в production (например, `BACKWARD`), чтобы ловить несовместимые схемы заранее.

## Чек-лист продюсера
Рекомендуемые значения, чтобы повторять гарантии продакшена:

```properties
enable.idempotence=true
acks=all
retries=Integer.MAX_VALUE
delivery.timeout.ms=120000
compression.type=zstd
linger.ms=5
batch.size=32768
```

`max.in.flight.requests.per.connection=1` — для строгого порядка сообщений; увеличивайте осторожно, если порядок не важен.

## Чек-лист консюмера

```properties
enable.auto.commit=false
isolation.level=read_committed
max.poll.records=200
partition.assignment.strategy=org.apache.kafka.clients.consumer.CooperativeStickyAssignor
```

Коммитьте оффсеты вручную (`commitSync`) только после успешной обработки. Потоки «читал из A, писал в B» оборачивайте в транзакции, чтобы чтение и запись либо коммитились, либо откатывались вместе.

## Темы и DLQ
- Основные темы и их `*.dlq` создаём заранее. Скрипт `scripts/create-topic-with-dlq.sh <topic>` поднимет `<topic>` и `<topic>.dlq` с `cleanup.policy=delete` и `retention.ms=172800000` (2 дня).
- Количество партиций ≥ максимального числа инстансов консюмера.

## Доступ локально
- Контейнеры обращаются к брокеру по хосту `kafka:19092` (внутренний слушатель). Указывайте этот bootstrap-адрес для сервисов внутри Docker.
- С хоста подключайтесь по `localhost:9092` (внешний слушатель). Если дедупликация DNS не срабатывает, проверьте, что `localhost` резолвится корректно и нет firewall, блокирующего порт.
