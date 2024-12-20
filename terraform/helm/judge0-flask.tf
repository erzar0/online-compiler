resource "random_password" "flask_secret" {
  length  = 32
  special = false
}

resource "helm_release" "judge0-flask" {
  name = "judge0-flask"

  chart            = "${path.module}/judge0-flask"
  version          = "0.1.0"
  namespace        = "judge0-flask"
  create_namespace = true

  set {
    name  = "env.redis.HOST"
    value = var.redis_ip
  }

  set_sensitive {
    name  = "env.redis.PASSWORD"
    value = var.redis_password
  }

  set {
    name  = "env.postgres.HOST"
    value = var.postgres_ip
  }

  set {
    name  = "env.postgres.USER"
    value = var.postgres_root_username
  }

  set_sensitive {
    name  = "env.postgres.PASSWORD"
    value = var.postgres_root_password
  }

  set_sensitive {
    name  = "env.flask.DATABASE_URL"
    value = "postgresql://${var.postgres_root_username}:${var.postgres_root_password}@${var.postgres_ip}:5432/${var.postgres_flask_database}"
  }

  set_sensitive {
    name  = "env.flask.SECRET_KEY"
    value = random_password.flask_secret.result
  }

  set {
    name  = "env.judge0.DATABASE_NAME"
    value = var.postgres_judge0_database
  }

  timeout    = 600
  depends_on = [var.redis_ip]
}