resource "kubernetes_namespace" "nextcloud" {
  metadata {
    name = "nextcloud"
  }
}

# https://github.com/nextcloud/helm/tree/master/charts/nextcloud
# Dashboard: https://grafana.com/grafana/dashboards/9632
# You need to add "127.0.0.1 nextcloud.nextcloud.svc.cluster.local" to your /etc/hosts files
resource "helm_release" "nextcloud" {
  depends_on = [helm_release.postgresql-ha]
  repository = "https://nextcloud.github.io/helm/"
  chart      = "nextcloud"
  name       = "nextcloud"

  namespace = kubernetes_namespace.nextcloud.metadata.0.name

  version = "2.5.16"

  wait    = true
  timeout = 2 * 60

  values = [
    <<EOF
nextcloud:
  host: nextcloud.nextcloud.svc.cluster.local:8080
  username: admin
  password: admin

service:
  type: LoadBalancer

internalDatabase:
  enabled: false

externalDatabase:
  enabled: true

  type: postgresql
  host: postgresql-postgresql-ha-pgpool.postgresql:5432

  user: nextcloud
  password: nextcloud
  database: nextcloud

persistence:
  enabled: true
  storageClass: hostpath

  size: 8Gi

metrics:
  enabled: true
EOF
  ]
}

resource "helm_release" "nextcloud-monitoring" {
  depends_on = [helm_release.nextcloud]
  chart      = "./nextcloud-monitor"
  name       = "nextcloud-monitor"

  namespace = kubernetes_namespace.nextcloud.metadata.0.name

  values = [
    <<EOF
matchLabels:
  app.kubernetes.io/instance: nextcloud
  app.kubernetes.io/managed-by: Helm
  app.kubernetes.io/name: nextcloud
namespaceSelector:
  - nextcloud
EOF
  ]
}