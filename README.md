# gcp-soccer-pipeline
This project is an end-to-end, serverless data pipeline built on Google Cloud Platform that fetches football fixture data from a third-party API, processes it using Apache Beam on Dataflow, and stores it in BigQuery for analysis.  The pipeline is orchestrated with Cloud Scheduler, triggered via Pub/Sub, and deployed entirely using Terraform.
