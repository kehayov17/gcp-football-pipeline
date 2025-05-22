resource "google_cloud_scheduler_job" "trigger_api_pipeline" {
  name        = "trigger-football-fixtures-pipeline"
  description = "Triggers the Cloud Function via Pub/Sub every 3 hours"
  schedule    = "0 */3 * * *"
  time_zone   = "Etc/UTC"

  pubsub_target {
    topic_name = google_pubsub_topic.trigger_topic.id
    data       = base64encode("{}")
  }
}
