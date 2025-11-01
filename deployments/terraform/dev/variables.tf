variable "kafka_bootstrap_servers" {
  type        = list(string)
  description = "List of Kafka bootstrap servers; defaults align with docker-compose dev environment."
  default     = ["localhost:9092"]
}

variable "topic_definitions" {
  type = map(object({
    partitions     = number
    retention_days = number
    cleanup_policy = optional(string)
    extra_config   = optional(map(string), {})
  }))

  description = <<-EOT
  Kafka topics managed for the dev environment with per-topic overrides.
  - partitions: desired partition count (per environment overrideable).
  - retention_days: log retention in days (converted to retention.ms).
  - cleanup_policy: optional per-topic cleanup policy override.
  - extra_config: optional map of additional per-topic configs.
  EOT

  default = {
    "chat.presence.events" = {
      partitions     = 3
      retention_days = 1
    }
    "chat.message.acks" = {
      partitions     = 6
      retention_days = 7
    }
    "chat.message.events" = {
      partitions     = 6
      retention_days = 7
    }
  }

  validation {
    condition = alltrue([
      for topic_name, topic in var.topic_definitions : (
        topic.partitions >= 1 &&
        topic.retention_days >= 1 &&
        (
          topic_name != "chat.presence.events" ||
          (topic.partitions >= 3 && topic.partitions <= 6 && topic.retention_days >= 1 && topic.retention_days <= 7)
        ) &&
        (
          topic_name != "chat.message.events" ||
          (topic.partitions >= 6 && topic.partitions <= 12 && topic.retention_days >= 7 && topic.retention_days <= 30)
        ) &&
        (
          topic_name != "chat.message.acks" ||
          (topic.partitions >= 6 && topic.partitions <= 12 && topic.retention_days >= 7 && topic.retention_days <= 30)
        )
      )
    ])

    error_message = "Topic definitions must respect documented partition and retention day ranges."
  }
}

variable "replication_factor" {
  type        = number
  description = "Replication factor for the dev topic (single broker by default)."
  default     = 1
}

variable "topic_cleanup_policy" {
  type        = string
  description = "Cleanup policy for the dev topic (delete or compact)."
  default     = "delete"
}

variable "topic_min_insync_replicas" {
  type        = number
  description = "Minimum in-sync replicas required for producer acks."
  default     = 1
}

variable "topic_segment_bytes" {
  type        = number
  description = "Segment file size threshold in bytes."
  default     = 104857600
}

variable "extra_topic_config" {
  type        = map(string)
  description = "Additional topic-level configuration overrides."
  default     = {}
}

variable "kafka_sasl_username" {
  type        = string
  description = "Optional SASL username for secured clusters."
  default     = ""
  nullable    = false
}

variable "kafka_sasl_password" {
  type        = string
  description = "Optional SASL password for secured clusters."
  default     = ""
  nullable    = false
  sensitive   = true
}

variable "kafka_sasl_mechanism" {
  type        = string
  description = "Optional SASL mechanism (e.g., PLAIN)."
  default     = ""
  nullable    = false
}
