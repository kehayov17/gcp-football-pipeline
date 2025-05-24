# gcp-football-pipeline
This project is an end-to-end, serverless data pipeline built on Google Cloud Platform that fetches football fixture data from a third-party API, processes it using Apache Beam on Dataflow, and stores it in BigQuery for analysis.  The pipeline is orchestrated with Cloud Scheduler, triggered via Pub/Sub, and deployed entirely using Terraform.
# Set-up
In the setup we will run Terraform to create the needed resources for the pipeline.We will configure only Dataflow manually.

1.Open your Cloud Shell and clone the repo:



2.Open the editor in Cloud Shell and edit the terraform.tfvars file to change the variables to your values:



3.Prepare the Cloud Functions source code.
When you use Terraform to create a Cloud function , a .zip is expected with the source code and a requirements.txt file.

Go back to the terminal and cd into the cloud-functions/api-to-pubsub directory:

Inside your cloud-functions/api-to-pubsub directory create a .zip package with your function code and requirements:


3.Deploy:


*Note : Terraform will enable all the needed apis upon deployment , but when you try to deploy for the first time you might encounter an error . Thats because the activation of the apis needs a couple of minutes , but Terraform proceeds to create the resources. If you get an error , just wait 2-3 minutes and run terraform apply --auto-approve again .This time the deployment should work.

After applying, Terraform will output useful info like:

Cloud Function name

Trigger topic name

Output topic name

#Configuring Dataflow
We will weite the code for the Dataflow job inside a User-managed Notebook in Vertex AI's Wokrbench.
