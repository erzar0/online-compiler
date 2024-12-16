resource "random_password" "flask_secret" {
  length = 32
  special = false
}

resource "helm_release" "judge0" {
  name = "judge0"

  chart            = "${path.module}/judge0-flask"
  version          = "0.1.0"
  namespace        = "judge0"
  create_namespace = true
  # values           = [file("${path.module}/values-judge0.yaml")]

  set {
    name  = "env.redis.HOST"
    value = var.redis_ip
  }

  set {
    name  = "env.postgres.HOST"
    value = var.postgres_ip
  }

  set {
    name  = "env.postgres.USER"
    value = var.postgres_root_username
  }

  set {
    name  = "env.postgres.PASSWORD"
    value = var.postgres_root_password
  }

  set {
    name  = "env.flask.DATABASE_URL"
    value = "postgresql://${var.postgres_root_username}:${var.postgres_root_password}@${var.postgres_ip}:5432/${var.postgres_flask_database}"
  }

  set {
    name  = "env.flask.SECRET_KEY"
    value = random_password.flask_secret.result
  }

  set {
    name  = "env.judge0.DATABASE_NAME"
    value = var.postgres_judge0_database
  }

  timeout = 600
}