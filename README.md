# gcp-football-pipeline
This project is an end-to-end, serverless data pipeline built on Google Cloud Platform that fetches football fixture data from a third-party API, processes it using Apache Beam on Dataflow, and stores it in BigQuery for analysis.  The pipeline is orchestrated with Cloud Scheduler, triggered via Pub/Sub, and deployed entirely using Terraform.
# Set-up
In the setup we will run Terraform to create the needed resources for the pipeline.We will configure only Dataflow manually.

1.Open your Cloud Shell and clone the repo:
```
git clone https://github.com/kehayov17/gcp-football-pipeline.git
```

2.Open the editor in Cloud Shell and edit the terraform.tfvars file to change the variables to your values:

<img width="307" alt="Screenshot 2025-05-24 at 12 41 05" src="https://github.com/user-attachments/assets/88fcb170-404e-47d3-8b8c-b99412616cd0" />


Open the function.tf file and change the env varibales to your api username and token:


<img width="429" alt="Screenshot 2025-05-24 at 12 41 17" src="https://github.com/user-attachments/assets/9b4fc9be-f500-4cd5-ba2e-de78cf85e912" />




3.Prepare the Cloud Functions source code.
When you use Terraform to create a Cloud function , a .zip is expected with the source code and a requirements.txt file.

Go back to the terminal and cd into the cloud-functions/api-to-pubsub directory:

Inside your cloud-functions/api-to-pubsub directory create a .zip package with your function code and requirements:
```
cd cloud-functions/api-to-pubsub
zip -r api-to-pubsub.zip main.py requirements.txt
```

3.Deploy:
Go back to the root dir and cd into terraform
```
cd terraform
```
Now run :
```
terrafrom init
```
```
terraform plan
```
```
terraform apply --auto-approve
```

*Note : Terraform will enable all the needed apis upon deployment , but when you try to deploy for the first time you might encounter an error . Thats because the activation of the apis needs a couple of minutes , but Terraform proceeds to create the resources. If you get an error , just wait 2-3 minutes and run terraform apply --auto-approve again .This time the deployment should work.

After applying, Terraform will output useful info like:

Cloud Function name

Trigger topic name

Output topic name

#Configuring Dataflow
1.Create staging and temp buckets for the pipeline from the cloud shell:
```
gcloud storage buckets create gs://temp_football_pipeline_bucket
gcloud storage buckets create gs://staging_football_pipeline_bucket
```
You can choose different names for the buckets , but make sure to remember them because we will need to specify them in the beam code.

2.Create a User-managed Notebook in Vertex AI's Workbench.
Wait until it's created and open the Notebook



3.Open a termninal once you're inside and clone the repo.
```
git clone https://github.com/kehayov17/gcp-football-pipeline.git
```
Go to dataflow-pipeline/main.py and open it.

Insert a cell above the code and run this command in it:
```
!pip install apache-beam[gcp]==2.50
```

Run the cell with the beam code.

The Dataflow job should be submitted . You can go back to GCP and navigate to Dataflow Jobs. The job should be running.
