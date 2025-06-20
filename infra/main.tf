
# terraform {
#   backend "gcs" {
#     bucket = "tfstate-gke-standard-renanmphp" # Use o mesmo nome do bucket que você criou
#     prefix = "standard-infra"             # Pasta para o estado da infraestrutura
#   }
# }
provider "google" {
  # Lembre-se de apontar para o SEU NOVO PROJETO
  project = "meu-projeto-prod"
  region  = "us-central1"
}

resource "google_container_cluster" "primary" {
  name     = "gke-standard-cluster"
  location = "us-central1"

  enable_autopilot = true

  monitoring_config {
    enable_components  = ["SYSTEM_COMPONENTS"]
    managed_prometheus {
      enabled = true
    }
  }
}