# gcp-football-pipeline
This project is an end-to-end, serverless data pipeline built on Google Cloud Platform that fetches football fixture data from a third-party API, processes it using Apache Beam on Dataflow, and stores it in BigQuery for analysis. The pipeline is orchestrated with Cloud Scheduler, triggered via Pub/Sub, and deployed entirely using Terraform.The pipeline uses the soccersapi.com API for football fixtures which has a free plan you can use to test and see how the pipeline works.

<img width="1386" alt="Screenshot 2025-05-25 at 17 54 52" src="https://github.com/user-attachments/assets/c74bcac1-eb39-4c17-a341-c8f4bdf9a27f" />

# Set-up
In the setup we will run Terraform to create the needed resources for the pipeline.We will configure only Dataflow manually.

Before we run Terraform we need to create two secrets in Secret Manager.

<img width="1080" alt="Screenshot 2025-05-25 at 17 51 14" src="https://github.com/user-attachments/assets/00140b7f-c965-4aa9-96be-735ecde0c715" />


Set the name of the secret for the token to ```football-api-token```
<img width="570" alt="Screenshot 2025-05-25 at 17 51 47" src="https://github.com/user-attachments/assets/ba8fc1d4-d7c8-4400-8248-864071341d13" />

And the name for the secret for the username to ```football-api-username```
<img width="565" alt="Screenshot 2025-05-25 at 17 51 36" src="https://github.com/user-attachments/assets/cda3c6bc-b40b-44d1-afd5-4fad41ac9958" />

**Important**

Make sure that the names match exatcly because we later reference these secrets in Terraform

**Setting up the pipeline**

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
```
cd cloud-functions/api-to-pubsub
```
Inside your cloud-functions/api-to-pubsub directory create a .zip package with your function code and requirements:
```
zip -r api-to-pubsub.zip main.py requirements.txt
```

3.Deploy

Go back to the root dir and cd into terraform:
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

# Configuring Dataflow

1.Create staging and temp buckets for the pipeline from the cloud shell:
```
gcloud storage buckets create gs://temp_football_pipeline_bucket
gcloud storage buckets create gs://staging_football_pipeline_bucket
```
You can choose different names for the buckets , but make sure to remember them because we will need to specify them in the beam code.

2.Create a User-managed Notebook in Vertex AI's Workbench.

<img width="517" alt="Screenshot 2025-05-24 at 12 44 35" src="https://github.com/user-attachments/assets/90a31d82-0519-42a3-9858-ef2dd2065b24" />

Wait until it's created and open the Notebook

<img width="147" alt="Screenshot 2025-05-24 at 12 44 46" src="https://github.com/user-attachments/assets/efe5ac04-685a-4fde-a92a-74f134359c12" />

3.Open a termninal once you're inside and clone the repo.

<img width="665" alt="Screenshot 2025-05-24 at 12 48 30" src="https://github.com/user-attachments/assets/65d8d3c6-573e-4318-9631-d8a795d5ba16" />


```
git clone https://github.com/kehayov17/gcp-football-pipeline.git
```
Go to dataflow-pipeline/main.py and open it.
Change the variables :
<img width="760" alt="Screenshot 2025-05-24 at 12 53 16" src="https://github.com/user-attachments/assets/0726acb1-3e9f-4776-8fd2-ef6360c5166f" />


Insert a cell above the code and run this command in it:

<img width="732" alt="Screenshot 2025-05-24 at 12 49 02" src="https://github.com/user-attachments/assets/4a1253fc-b0cd-411a-9e10-430c2ed12c6a" />


```
!pip install apache-beam[gcp]==2.50
```
Wait for beam to install.
Run the cell with the beam code.

The Dataflow job should be submitted . You can go back to GCP and navigate to Dataflow Jobs. The job should be running. Cloud Shechduler is configured to send an empty json string to the trigger topic every 3 hours . The Cloud function listens to the trigger topic and calls the api , after that it sends the json message from the api containing the football fixture to the output topic. The Dataflow job gets the messages from this topic and after processing them it writes them to BigQuery for storage and analysis.
