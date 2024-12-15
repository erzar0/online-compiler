module "helm" {
  source = "./helm"

  redis_ip   = google_redis_instance.redis_instance.host
  redis_port = google_redis_instance.redis_instance.port

  postgres_ip            = google_sql_user.root.host
  postgres_root_username = google_sql_user.root.name
  postgres_root_password = google_sql_user.root.password
  postgres_database      = google_sql_database.judge0.instance
}
