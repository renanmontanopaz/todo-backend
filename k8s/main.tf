# O provedor do Kubernetes.
provider "kubernetes" {}

# O provedor do Helm.
provider "helm" {
  kubernetes = {}
}

# Cria o namespace para o Grafana
# resource "kubernetes_namespace" "monitoring" {
#   metadata {
#     name = "monitoring"
#   }
# }

# --- LINHA ADICIONADA AQUI ---
# Cria o namespace para a aplicação
resource "kubernetes_namespace" "production" {
  metadata {
    name = "production"
  }
}
# -----------------------------

# Instala o Grafana
resource "helm_release" "grafana" {
  name       = "grafana-dashboard"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name

  depends_on = [kubernetes_namespace.monitoring]
}