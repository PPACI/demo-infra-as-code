resource "kubernetes_namespace" "postgresql" {
  metadata {
    name = "postgresql"
  }
}

# https://github.com/bitnami/charts/tree/master/bitnami/postgresql-ha
# Dashboard: https://grafana.com/grafana/dashboards/9628
resource "helm_release" "postgresql-ha" {
  depends_on = [helm_release.kube-prometheus-stack]
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "postgresql-ha"
  name       = "postgresql"

  version = "6.8.0"

  namespace = kubernetes_namespace.postgresql.metadata.0.name

  wait = true

  values = [
    <<EOF
postgresql:
  username: postgres
  password: postgres
  repmgrUsername: repmgr
  repmgrPassword: repmgr
  initdbScripts:
    create-db.sql: |
      CREATE USER nextcloud PASSWORD 'nextcloud';
      CREATE DATABASE nextcloud OWNER nextcloud;
  resources:
    requests:
      memory: 256Mi
      cpu: 500m
    limits:
      memory: 256Mi
      cpu: 1000m

pgpool:
  numInitChildren: 5
  adminUsername: admin
  adminPassword: admin
  customUsers:
    usernames: nextcloud
    passwords: nextcloud

persistence:
  enabled: true
  storageClass: hostpath
  size: 8Gi

metrics:
  enabled: true
  serviceMonitor:
    enabled: true

service:
  type: LoadBalancer
EOF
  ]
}