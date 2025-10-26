# Список адресов брокеров Kafka, к которым подключается Terraform
variable "kafka_bootstrap_servers" {
  type        = list(string)
  description = "List of Kafka bootstrap servers; defaults align with docker-compose dev environment."
  default     = ["localhost:9092"]
}

# Список Kafka-топиков, которые Terraform создаёт в dev-окружении
variable "topic_names" {
  type        = set(string)
  description = "Kafka topic names managed for the dev environment."
  default     = ["test-topic"]
}

# Количество партиций на каждый создаваемый топик
variable "topic_partitions" {
  type        = number
  description = "Number of partitions for the dev topic (aligns with KAFKA_NUM_PARTITIONS)."
  default     = 3
}

# Фактор репликации (в dev стоит 1, потому что один брокер)
variable "replication_factor" {
  type        = number
  description = "Replication factor for the dev topic (single broker by default)."
  default     = 1
}

# Базовая политика очистки логов топика
variable "topic_cleanup_policy" {
  type        = string
  description = "Cleanup policy for the dev topic (delete or compact)."
  default     = "delete"
}

# Минимальное количество реплик, которые должны подтвердить запись
variable "topic_min_insync_replicas" {
  type        = number
  description = "Minimum in-sync replicas required for producer acks."
  default     = 1
}

# Размер сегмента логов (байт)
variable "topic_segment_bytes" {
  type        = number
  description = "Segment file size threshold in bytes."
  default     = 104857600
}

# Дополнительные кастомные настройки топика
variable "extra_topic_config" {
  type        = map(string)
  description = "Additional topic-level configuration overrides."
  default     = {}
}

# Настройки SASL для подключения к защищённым кластерам (по умолчанию пустые)
variable "kafka_sasl_username" {
  type        = string
  description = "Optional SASL username for secured clusters."
  default     = ""
  nullable    = false
}

# Пароль для SASL-аутентификации (если требуется)
variable "kafka_sasl_password" {
  type        = string
  description = "Optional SASL password for secured clusters."
  default     = ""
  nullable    = false
  sensitive   = true
}

# Используемый SASL-механизм (например, PLAIN)
variable "kafka_sasl_mechanism" {
  type        = string
  description = "Optional SASL mechanism (e.g., PLAIN)."
  default     = ""
  nullable    = false
}
