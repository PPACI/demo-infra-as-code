resource "helm_release" "kube-state-metrics" {
  repository = "https://kubernetes.github.io/kube-state-metrics"
  chart      = "kube-state-metrics"
  name       = "kube-state-metrics"

  namespace = "kube-system"

  version = "2.13.0"

  wait = true
}