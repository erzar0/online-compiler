resource "helm_release" "judge0" {
  name = "judge0"

  chart            = "${path.module}/judge0"
  version          = "0.1.0"
  namespace        = "judge0"
  create_namespace = true
  values           = [file("${path.module}/values-judge0.yaml")]

  set {
    name  = "redis.host"
    value = var.redis_ip
  }

  set {
    name  = "redis.port"
    value = var.redis_port
  }

  set {
    name  = "postgres.host"
    value = var.postgres_ip
  }

  set {
    name  = "postgres.database"
    value = var.postgres_ip
  }

  set {
    name  = "postgres.username"
    value = var.postgres_root_username
  }

  set {
    name  = "postgres.password"
    value = var.postgres_root_password
  }
}