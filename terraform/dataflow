# You will deploy the Dataflow pipeline manually , this just gives the compute engine SA permissions to use Dataflow

resource "google_project_iam_member" "compute_service_account_dataflow" {
  project = var.project_id
  role    = "roles/dataflow.serviceAgent"
  member  = "serviceAccount:${var.project_number}-compute@developer.gserviceaccount.com"
}
