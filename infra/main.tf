provider "google" {
  # Lembre-se de apontar para o SEU NOVO PROJETO
  project = "meu-projeto-prod"
  region  = "us-central1"
}

# resource "google_container_cluster" "primary" {
#   name     = "gke-standard-cluster"
#   location = "us-central1"
#
#   # Remove o pool de nós padrão para criarmos um customizado
#   remove_default_node_pool = true
#   initial_node_count       = 3
# }

resource "google_container_node_pool" "primary_nodes" {
  name       = "default-pool"
  cluster    = google_container_cluster.primary.name
  location   = google_container_cluster.primary.location
  node_count = 3 # Começamos com 1 nó, mas podemos habilitar o autoscaling

  node_config {
    # e2-medium é uma máquina boa e de custo-benefício para começar
    machine_type = "e2-micro"
    disk_size_gb = 50

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}