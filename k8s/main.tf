
# Provedores Kubernetes e Helm (a configuração agora é inferida pelo ambiente da pipeline)
provider "kubernetes" {}
provider "helm" {}

# Cria o namespace para a aplicação
# resource "kubernetes_namespace" "production" {
#   metadata {
#     name = "production"
#   }
# }
#
# # Cria o namespace para o monitoramento
# resource "kubernetes_namespace" "monitoring" {
#   metadata {
#     name = "monitoring"
#   }
# }

# Instala a PILHA COMPLETA de monitoramento
resource "helm_release" "prometheus_stack" {
  name       = "prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name

  # Garante que a instalação do Helm só ocorrerá após a criação do namespace
  depends_on = [kubernetes_namespace.monitoring]
}