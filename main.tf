# Define que vamos usar o Terraform para gerenciar recursos no Google Cloud
provider "google" {
  project = "meu-projeto-stage" # Substitua pelo ID do seu projeto
  region  = "us-central1"
}

# --- CORREÇÃO AQUI ---
# Define o provedor do Kubernetes. Note o sinal de igual.
provider "kubernetes" {
  host                   = "https://$(data.google_container_cluster.primary.endpoint)"
  cluster_ca_certificate = base64decode(data.google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
  token                  = data.google_client_config.default.access_token
}

# --- CORREÇÃO AQUI ---
# Define o provedor do Helm para instalar o Grafana. Note o sinal de igual no argumento "kubernetes".
provider "helm" {
  kubernetes = {
    host                   = "https://$(data.google_container_cluster.primary.endpoint)"
    cluster_ca_certificate = base64decode(data.google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
    token                  = data.google_client_config.default.access_token
  }
}

# Obtém as informações do cluster GKE depois que ele for criado, para configurar os outros provedores
data "google_container_cluster" "primary" {
  name     = google_container_cluster.primary.name
  location = google_container_cluster.primary.location
  project  = google_container_cluster.primary.project

  # Garante que este data source só será lido após a criação do cluster
  depends_on = [google_container_cluster.primary]
}

# Obtém as credenciais de acesso para autenticar no cluster
data "google_client_config" "default" {}

# Recurso principal: O Cluster GKE Autopilot
resource "google_container_cluster" "primary" {
  name     = "autopilot-cluster-stage"
  location = "us-central1"

  # Habilita o modo Autopilot
  enable_autopilot = true

  # Habilita o Google Cloud Managed Service for Prometheus
  monitoring_config {
    managed_prometheus {
      enabled = true
    }
  }
}

# Recurso para criar o namespace "monitoring" onde o Grafana será instalado
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }

  # Garante que o namespace só será criado após o cluster existir
  depends_on = [google_container_cluster.primary]
}

# Recurso para instalar o Grafana usando o Helm
resource "helm_release" "grafana" {
  name       = "grafana-dashboard"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name

  # Garante que a instalação do Helm só ocorrerá após a criação do namespace
  depends_on = [kubernetes_namespace.monitoring]
}