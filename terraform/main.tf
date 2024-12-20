module "helm" {
  source = "./helm"

  redis_ip       = google_redis_instance.redis_instance.host
  redis_password = google_redis_instance.redis_instance.auth_string

  postgres_ip              = google_sql_database_instance.postgres_instance.private_ip_address
  postgres_root_username   = google_sql_user.root.name
  postgres_root_password   = google_sql_user.root.password
  postgres_judge0_database = google_sql_database.judge0.name
  postgres_flask_database  = google_sql_database.flask.name

  depends_on = [ google_redis_instance.redis_instance, google_sql_database_instance.postgres_instance]
}
