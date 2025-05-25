resource "google_storage_bucket" "function_bucket" {
  name          = "${var.project_id}-function-bucket"
  location      = var.region
  force_destroy = true
}

resource "google_storage_bucket_object" "function_zip" {
  name   = "api-to-pubsub.zip"
  bucket = google_storage_bucket.function_bucket.name
  source = "${var.function_source_dir}/api-to-pubsub.zip"
}

resource "google_cloudfunctions2_function" "api_to_pubsub" {
  name     = "api-to-pubsub"
  location = var.region

  build_config {
    runtime     = "python310"
    entry_point = "fetch_and_publish"
    source {
      storage_source {
        bucket = google_storage_bucket.function_bucket.name
        object = google_storage_bucket_object.function_zip.name
      }
    }
  }

  service_config {
    available_memory = "256M"
    timeout_seconds  = 60
    environment_variables = {
      user         = data.google_secret_manager_secret_version.api_user.secret_data
      token        = data.google_secret_manager_secret_version.api_token.secret_data
      project-id   = var.project_id
      pubsub-topic = google_pubsub_topic.output_topic.name
    }
    ingress_settings = "ALLOW_ALL"
  }

  event_trigger {
    trigger_region = var.region
    event_type     = "google.cloud.pubsub.topic.v1.messagePublished"
    pubsub_topic   = google_pubsub_topic.trigger_topic.id
    retry_policy   = "RETRY_POLICY_RETRY"
  }
}

resource "google_project_iam_member" "pubsub_publisher" {
  project = var.project_id
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${google_cloudfunctions2_function.api_to_pubsub.service_config[0].service_account_email}"
}
