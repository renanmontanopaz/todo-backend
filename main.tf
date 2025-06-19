# Define que vamos usar o Terraform para gerenciar recursos no Google Cloud
provider "google" {
  project = "meu-projeto-stage" # Substitua pelo ID do seu projeto
  region  = "us-central1"
}

# Obtém as credenciais de acesso para autenticar no cluster.
data "google_client_config" "default" {}

# Recurso principal: O Cluster GKE Autopilot
resource "google_container_cluster" "primary" {
  name     = "autopilot-cluster-stage"
  location = "us-central1"

  # Habilita o modo Autopilot
  enable_autopilot = true

  # Habilita o Google Cloud Managed Service for Prometheus e os componentes de sistema
  monitoring_config {
    enable_components = ["SYSTEM_COMPONENTS"]
    managed_prometheus {
      enabled = true
    }
  }
}

# --- CORREÇÃO FINAL AQUI ---
# Define o provedor do Helm. Note a sintaxe de interpolação correta com ${...}
provider "helm" {
  kubernetes = {
    host                   = "https://_**$**_{google_container_cluster.primary.endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
  }
}

# Define o provedor do Kubernetes. Note a sintaxe de interpolação correta com ${...}
provider "kubernetes" {
  host                   = "https://_**$**_{google_container_cluster.primary.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
}

# Recurso para criar o namespace "monitoring" onde o Grafana será instalado
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

# Recurso para instalar o Grafana usando o Helm
resource "helm_release" "grafana" {
  name       = "grafana-dashboard"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name

  depends_on = [kubernetes_namespace.monitoring]
}