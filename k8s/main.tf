# O provedor do Kubernetes. Ele será configurado automaticamente pela pipeline
# que já terá as credenciais do cluster criado no passo anterior.
provider "kubernetes" {}

# O provedor do Helm.
provider "helm" {
  kubernetes = {}
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

resource "helm_release" "grafana" {
  name       = "grafana-dashboard"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name

  depends_on = [kubernetes_namespace.monitoring]
}