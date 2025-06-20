terraform {
  backend "gcs" {
    bucket = "tfstate-gke-standard-renanmphp" # Use o mesmo nome do bucket que você criou
    prefix = "standard-infra"             # Pasta para o estado da infraestrutura
  }
}
# Provedores Kubernetes e Helm (a configuração agora é inferida pelo ambiente da pipeline)
provider "kubernetes" {}
provider "helm" {}

# Cria o namespace para a aplicação
resource "kubernetes_namespace" "production" {
  metadata {
    name = "production"
  }
}
#
# # Cria o namespace para o monitoramento
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}
#
resource "helm_release" "grafana" {
  name       = "grafana-dashboard"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name

  depends_on = [kubernetes_namespace.monitoring]
}