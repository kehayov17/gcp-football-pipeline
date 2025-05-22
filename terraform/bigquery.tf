resource "google_bigquery_dataset" "soccer_dataset" {
  dataset_id = "soccer_api_dataset"
  project    = var.project_id
  location   = var.region
  description = "Dataset for soccer fixtures data"
}

resource "google_bigquery_table" "soccer_table" {
  dataset_id = google_bigquery_dataset.soccer_dataset.dataset_id
  table_id   = "soccer_api_table"
  project    = var.project_id

  schema = <<EOF
[
  {"name": "id", "type": "STRING", "mode": "NULLABLE"},
  {"name": "home_team_name", "type": "STRING", "mode": "NULLABLE"},
  {"name": "away_team_name", "type": "STRING", "mode": "NULLABLE"},
  {"name": "stadium_name", "type": "STRING", "mode": "NULLABLE"},
  {"name": "league_id", "type": "STRING", "mode": "NULLABLE"},
  {"name": "league_name", "type": "STRING", "mode": "NULLABLE"},
  {"name": "home_score", "type": "INTEGER", "mode": "NULLABLE"},
  {"name": "away_score", "type": "INTEGER", "mode": "NULLABLE"},
  {"name": "referee_id", "type": "STRING", "mode": "NULLABLE"},
  {"name": "referee_name", "type": "STRING", "mode": "NULLABLE"},
  {"name": "match_date", "type": "TIMESTAMP", "mode": "NULLABLE"},
  {"name": "winner_team_id", "type": "STRING", "mode": "NULLABLE"},
  {"name": "home_team_id", "type": "STRING", "mode": "NULLABLE"},
  {"name": "away_team_id", "type": "STRING", "mode": "NULLABLE"},
  {"name": "country_id", "type": "STRING", "mode": "NULLABLE"},
  {"name": "country_name", "type": "STRING", "mode": "NULLABLE"},
  {"name": "ht_score", "type": "STRING", "mode": "NULLABLE"},
  {"name": "ft_score", "type": "STRING", "mode": "NULLABLE"}
]
EOF

  time_partitioning {
    type = "DAY"
    field = "match_date"
  }

  expiration_time = null

  labels = {
    environment = "dev"
    team        = "soccer-data"
  }
}
