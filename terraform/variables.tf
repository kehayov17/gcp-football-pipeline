variable "project_id" {}
variable "region" {default="us-central1"}
variable "function_source_dir" { default = "../cloud-functions/api-to-pubsub" }
variable "pubsub_output_topic" { default = "football-api-topic" }
variable "project_number" {}
