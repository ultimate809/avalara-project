# Define the Kubernetes provider
provider "kubernetes" {
  config_path = "~/.kube/config"
}

# Define the Redis Pod
resource "kubernetes_pod" "redis" {
  metadata {
    name      = "redis"
    namespace = kubernetes_namespace.avalara_tests.metadata.0.name
    labels = {
      name = "redis"
    }
  }

  spec {
    container {
      name  = "redis"
      image = "redis:latest"
      port {
        container_port = 6379
      }

      volume_mount {
        name       = "redis-storage"
        mount_path = "/data"
      }
    }

    volume {
      name = "redis-storage"
      persistent_volume_claim {
        claim_name = kubernetes_persistent_volume_claim.redis-pvc.metadata.0.name
      }
    }
  }
}

# Define the Redis Service
resource "kubernetes_service" "redis-clusterip" {
  metadata {
    name      = "redis-clusterip"
    namespace = "kubernetes_namespace.avalara_tests.metadata.0.name"
  }

  spec {
    selector = {
      name = "redis"
    }

    port {
      port        = 2409
      target_port = 6379
      protocol    = "TCP"
    }
  }
}

# Define the Redis Ingress
resource "kubernetes_ingress" "redis-ingress" {
  metadata {
    name      = "redis-ingress"
    namespace = "kubernetes_namespace.avalara_tests.metadata.0.name"
  }

  spec {
    ingress_class_name = "nginx"

    rule {
      host = "avalara.redis.com"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service_name = kubernetes_service.redis-clusterip.metadata.0.name
            service_port = 2409
          }
        }
      }
    }
  }
}

# Define the Redis Persistent Volume
resource "kubernetes_persistent_volume" "redis-pv" {
  metadata {
    name = "redis-pv"
  }

  spec {
    capacity = {
      storage = "1Gi"
    }

    access_modes = ["ReadWriteOnce"]

    host_path {
      path = "/mnt/data"
    }
  }
}

# Define the Redis Persistent Volume Claim
resource "kubernetes_persistent_volume_claim" "redis-pvc" {
  metadata {
    name      = "redis-pvc"
    namespace = "kubernetes_namespace.avalara_tests.metadata.0.name"
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = "1Gi"
      }
    }
  }
}