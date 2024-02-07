provider "kubernetes" {
  config_path    = "kubeconfig" 
}

resource "kubernetes_config_map" "index" {
  metadata {
    name = "index"
    namespace = "candidate-e"
  }

  data = {
    "index.txt" = "Hi, How are you doing "
  }
}

# ConfigMap for config
resource "kubernetes_config_map" "config" {
  metadata {
    name = "config"
    namespace = "candidate-e"
  }

  data = {
    "config.html" = <<HTML
<!DOCTYPE html>
<html lang="en">
<body>
    <h1>Hello, World from config *!</h1> 
</body>
</html> 
HTML
}

}

# Deployment
resource "kubernetes_deployment" "nginx" {
  metadata {
    name = "nginx"
    namespace = "candidate-e"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "nginx"
      }
    }

    template {
      metadata {
        labels = {
          app = "nginx"
        }
      }

      spec {
        container {
          name  = "nginx"
          image = var.nginx_image

          volume_mount {
            name       = "config"
            mount_path = "/home/demo/config.html"
            sub_path   = "config.html"
          }

          volume_mount {
            name       = "index"
            mount_path = "/home/demo/index.txt"
            sub_path   = "index.txt"
          }
        }

        volume {
          name = "index"

          config_map {
            name = kubernetes_config_map.index.metadata.0.name

            items {
              key  = "index.txt"
              path = "index.txt"
            }
          }
        }

        volume {
          name = "config"

          config_map {
            name = kubernetes_config_map.config.metadata.0.name

            items {
              key  = "config.html"
              path = "config.html"
            }
          }
        }
      }
    }
  }
}

# Service
resource "kubernetes_service" "nginx" {
  metadata {
    name = "nginx"
    namespace = "candidate-e"
  }

  spec {
    selector = {
      app = "nginx"
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "LoadBalancer"
  }
}

