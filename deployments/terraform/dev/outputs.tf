# Возвращаем список имён топиков, созданных этим стэком
output "topic_names" {
  description = "Kafka topics managed by this Terraform stack."
  value       = [for topic in kafka_topic.dev : topic.name]
}
