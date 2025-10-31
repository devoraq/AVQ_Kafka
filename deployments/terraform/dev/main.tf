terraform {
  required_version = ">= 1.5.0"

  required_providers {
    kafka = {
      source  = "Mongey/kafka"
      version = "~> 0.5"
    }
  }
}

provider "kafka" {
  bootstrap_servers = var.kafka_bootstrap_servers
  tls_enabled       = false
  skip_tls_verify   = true
  sasl_username     = trimspace(var.kafka_sasl_username) != "" ? var.kafka_sasl_username : null
  sasl_password     = trimspace(var.kafka_sasl_password) != "" ? var.kafka_sasl_password : null
  sasl_mechanism    = trimspace(var.kafka_sasl_mechanism) != "" ? var.kafka_sasl_mechanism : null
}

locals {
  default_topic_config = {
    "cleanup.policy"      = var.topic_cleanup_policy
    "min.insync.replicas" = tostring(var.topic_min_insync_replicas)
    "segment.bytes"       = tostring(var.topic_segment_bytes)
  }
}

resource "kafka_topic" "dev" {
  for_each           = var.topic_definitions
  name               = each.key
  replication_factor = var.replication_factor
  partitions         = each.value.partitions

  config = {
    for k, v in merge(
      local.default_topic_config,
      var.extra_topic_config,
      each.value.cleanup_policy != null && trimspace(each.value.cleanup_policy) != "" ? {
        "cleanup.policy" = each.value.cleanup_policy
      } : {},
      try(each.value.extra_config, {}),
      {
        "retention.ms" = tostring(each.value.retention_days * 24 * 60 * 60 * 1000)
      }
    ) : k => v if trimspace(v) != ""
  }
}
