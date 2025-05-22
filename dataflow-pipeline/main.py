import apache_beam as beam
from apache_beam.options.pipeline_options import PipelineOptions, StandardOptions
import json
from datetime import datetime

def parse_pubsub_message(message):
    fixture = json.loads(message.decode('utf-8'))

    def safe_get(d, *keys):
        for key in keys:
            d = d.get(key, {})
        return d if d != {} else None

    # Convert match_date to ISO 8601 timestamp for BigQuery
    match_date_str = fixture.get("time", {}).get("datetime")
    match_date = None
    if match_date_str:
        try:
            dt = datetime.strptime(match_date_str, "%Y-%m-%d %H:%M:%S")
            match_date = dt.isoformat() + "Z"
        except Exception:
            match_date = None
def is_finished_match(fixture):
    return fixture.get("status") == 3

    row = {
        "id": fixture.get("id"),
        "home_team_name": safe_get(fixture, "teams", "home", "name"),
        "away_team_name": safe_get(fixture, "teams", "away", "name"),
        "stadium_name": fixture.get("venue_id"),
        "league_id": safe_get(fixture, "league", "id"),
        "league_name": safe_get(fixture, "league", "name"),
        "home_score": fixture.get("scores", {}).get("home_score"),
        "away_score": fixture.get("scores", {}).get("away_score"),
        "referee_id": fixture.get("referee_id"),
        "referee_name": None,
        "match_date": match_date,
        "winner_team_id": fixture.get("winner_team_id"),
        "home_team_id": safe_get(fixture, "teams", "home", "id"),
        "away_team_id": safe_get(fixture, "teams", "away", "id"),
        "country_id": safe_get(fixture, "league", "country_id"),
        "country_name": safe_get(fixture, "league", "country_name"),
        "ht_score": fixture.get("scores", {}).get("ht_score"),
        "ft_score": fixture.get("scores", {}).get("ft_score"),
    }
    return row

def run(argv=None):
    options = PipelineOptions(runner='DataflowRunner',  # Use DirectRunner locally if you want local run
    project='your-gcp-project',
    temp_location='gs://type-your-temp-bucket-here',
    staging_location='gs://type-your-staging-bucket-here',
    region='type-your-region-here')
    options.view_as(StandardOptions).streaming = True  # Streaming mode
    topic_variable='type-your-pubsub-topic-here'
    bq_table='your-project:your-bq-dataset.your-bq-table'
    bq_schema="""
                    id:STRING,
                    home_team_name:STRING,
                    away_team_name:STRING,
                    stadium_name:STRING,
                    league_id:STRING,
                    league_name:STRING,
                    home_score:INTEGER,
                    away_score:INTEGER,
                    referee_id:STRING,
                    referee_name:STRING,
                    match_date:TIMESTAMP,
                    winner_team_id:STRING,
                    home_team_id:STRING,
                    away_team_id:STRING,
                    country_id:STRING,
                    country_name:STRING,
                    ht_score:STRING,
                    ft_score:STRING
                """
    with beam.Pipeline(options=options) as p:
        (
            p
            | "ReadFromPubSub" >> beam.io.ReadFromPubSub(topic=topic_variable)
            | "ParseMessage" >> beam.Map(parse_pubsub_message)
            | "FilterFinishedMatches" >> beam.Filter(is_finished_match)
            | "WriteToBigQuery" >> beam.io.WriteToBigQuery(
                table=bq_table,
                schema=bq_schema,
                write_disposition=beam.io.BigQueryDisposition.WRITE_APPEND,
                create_disposition=beam.io.BigQueryDisposition.CREATE_IF_NEEDED,
            )
        )

if __name__ == "__main__":
    run()
