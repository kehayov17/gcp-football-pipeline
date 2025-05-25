data "google_secret_manager_secret_version" "api_user" {
  secret  = "football-api-username"
  project = var.project_id
}

data "google_secret_manager_secret_version" "api_token" {
  secret  = "football-api-token"
  project = var.project_id
}
