resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

# https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack
resource "helm_release" "kube-prometheus-stack" {
  depends_on = [helm_release.kube-state-metrics]
  repository = "https://prometheus-community.github.io/helm-charts"
  chart = "kube-prometheus-stack"
  name  = "monitoring"

  version = "14.4.0"

  namespace = kubernetes_namespace.monitoring.metadata.0.name

  wait = true

  values = [
  <<EOF
prometheus:
  prometheusSpec:
    storageSpec:
      volumeClaimTemplate:
        spec:
          storageClassName: hostpath
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 5Gi
    retention: 10d
    serviceMonitorSelectorNilUsesHelmValues: false
    podMonitorSelectorNilUsesHelmValues: false
    resources:
      requests:
        memory: 500Mi
        cpu: 300m
      limits:
        memory: 500Mi
        cpu: 500m

nodeExporter:
  enabled: false

grafana:
  sidecar:
    searchNamespace: ALL
  adminPassword: admin
  persistence:
    enabled: true
    storageClassName: hostpath
    size: 2Gi
  service:
    type: LoadBalancer
    port: 8081
  resources:
    requests:
      memory: 100Mi
      cpu: 100m
    limits:
      memory: 100Mi
      cpu: 200m
EOF
]
}