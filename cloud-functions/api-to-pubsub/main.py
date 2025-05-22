import base64
import functions_framework

@functions_framework.cloud_event
def fetch_and_publish(cloud_event):
    import os
    import requests
    import json
    from datetime import datetime
    from google.cloud import pubsub_v1

    # Environment variables
    username = os.getenv("user")
    token = os.getenv("token")
    project_id = os.getenv("project-id")
    topic_name = os.getenv("pubsub-topic")

    if not all([username, token, project_id, topic_name]):
        print("Missing environment variables")
        return

    # Construct API URL
    today = datetime.utcnow().strftime("%Y-%m-%d")
    url = f"https://api.soccersapi.com/v2.2/fixtures/?user={username}&token={token}&t=schedule&d={today}"

    response = requests.get(url)
    if response.status_code != 200:
        print(f"API error: {response.status_code}")
        return

    data = response.json()
    fixtures = data.get("data", [])

    publisher = pubsub_v1.PublisherClient()
    topic_path = publisher.topic_path(project_id, topic_name)

    for fixture in fixtures:
        message = json.dumps(fixture).encode("utf-8")
        future = publisher.publish(topic_path, data=message)
        print(f"Published message ID: {future.result()}")

    print(f"Published {len(fixtures)} messages.")
