variable "project_id" {}
variable "region" {default="us-central1"}
variable "function_source_dir" { default = "../cloud-functions/api-to-pubsub" }
variable "dataflow_temp_location" {}
variable "dataflow_staging_location" {}
variable "pubsub_output_topic" { default = "soccer-api-topic" }
