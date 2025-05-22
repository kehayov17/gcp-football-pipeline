output "cloud_function_url" {
  value = google_cloudfunctions2_function.api_to_pubsub.name
}

output "trigger_topic" {
  value = google_pubsub_topic.trigger_topic.name
}

output "output_topic" {
  value = google_pubsub_topic.output_topic.name
}
