terraform {
  # https://www.terraform.io/docs/language/settings/backends/kubernetes.html
  backend "kubernetes" {
    config_path = "~/.kube/config"
    config_context = "docker-desktop"
    secret_suffix = "poc"
  }
}

# https://www.terraform.io/docs/language/settings/backends/kubernetes.html
provider "kubernetes" {
  config_path = "~/.kube/config"
  config_context = "docker-desktop"
}

# https://registry.terraform.io/providers/hashicorp/helm/latest
provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
    config_context = "docker-desktop"
  }
}