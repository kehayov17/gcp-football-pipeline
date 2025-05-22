resource "google_pubsub_topic" "trigger_topic" {
  name = "scheduler-trigger"
}

resource "google_pubsub_topic" "output_topic" {
  name = var.pubsub_output_topic
}

resource "google_pubsub_topic_iam_binding" "allow_scheduler_publish" {
  topic = google_pubsub_topic.trigger_topic.name

  role    = "roles/pubsub.publisher"
  members = [
    "serviceAccount:${var.project_number}-compute@developer.gserviceaccount.com"
  ]
}
