# Define the Kubernetes provider
provider "kubernetes" {
  config_path = "~/.kube/config"
}

# Create a namespace
resource "kubernetes_namespace" "avalara_tests" {
  metadata {
    name = "avalara-automation"
  }
}

# Create a deployment for green
resource "kubernetes_deployment" "green_deployment" {
  metadata {
    name      = "green-deployment"
    namespace = kubernetes_namespace.avalara_tests.metadata.0.name
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        name = "green-pod"
      }
    }

    template {
      metadata {
        labels = {
          name = "green-pod"
        }
      }

      spec {
        container {
          name  = "green-pod"
          image = "argoproj/rollouts-demo:green"

          port {
            container_port = 8080
          }
        }
      }
    }
  }
}

# Create a service for green
resource "kubernetes_service" "green_primary" {
  metadata {
    name      = "green-primary"
    namespace = kubernetes_namespace.avalara_tests.metadata.0.name
  }

  spec {
    selector = {
      name = "green-pod"
    }

    port {
      port        = 2409
      target_port = 8080
    }
  }
}

# Create an ingress for green
resource "kubernetes_ingress_v1" "green_ingress" {
  metadata {
    name        = "green-ingress"
    namespace   = kubernetes_namespace.avalara_tests.metadata.0.name
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
    }
  }

  spec {
    ingress_class_name = "nginx"
    rule {
      host = "avalara.project.com"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.green_primary.metadata.0.name
              port {
                number = 2409
              }
            }
          }
        }
      }
    }
  }
}

# Create a deployment
resource "kubernetes_deployment" "blue_deployment" {
  metadata {
    name      = "blue-deployment"
    namespace = kubernetes_namespace.avalara_tests.metadata.0.name
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        name = "blue-pod"
      }
    }

    template {
      metadata {
        labels = {
          name = "blue-pod"
        }
      }

      spec {
        container {
          name  = "blue-pod"
          image = "argoproj/rollouts-demo:blue"

          port {
            container_port = 8080
          }
        }
      }
    }
  }
}

# Create a service
resource "kubernetes_service" "blue_canary" {
  metadata {
    name      = "blue-canary"
    namespace = kubernetes_namespace.avalara_tests.metadata.0.name
  }

  spec {
    selector = {
      name = "blue-pod"
    }

    port {
      port        = 2409
      target_port = 8080
    }
  }
}

# Create an ingress for blue
resource "kubernetes_ingress_v1" "blue_ingress" {
  metadata {
    name      = "blue-ingress"
    namespace = kubernetes_namespace.avalara_tests.metadata.0.name
    annotations = {
      "kubernetes.io/ingress.class"                 = "nginx"
      "ingress.kubernetes.io/rewrite-target"        = "/"
      "nginx.ingress.kubernetes.io/canary"          = "true"
      "nginx.ingress.kubernetes.io/canary-weight"   = "20"
    }
  }

  spec {
    ingress_class_name = "nginx"
    rule {
      host = "avalara.project.com"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.blue_canary.metadata.0.name
              port {
                number = 2409
              }
            }
          }
        }
      }
    }
  }
}