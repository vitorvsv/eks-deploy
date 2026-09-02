resource "aws_secretsmanager_secret" "users_api_mongodb" {
  name                    = "eks-deploy/users-api/mongodb-connection-uri"
  description             = "MongoDB connection string (MONGODB_CONNECTION_URI) used by users-api"
  recovery_window_in_days = 7

  tags = local.common_tags
}

variable "users_api_mongodb_connection_uri" {
  description = "MongoDB connection URI for users-api. When empty, the secret is created without a value."
  type        = string
  sensitive   = true
  default     = ""
}

resource "aws_secretsmanager_secret_version" "users_api_mongodb" {
  count = var.users_api_mongodb_connection_uri != "" ? 1 : 0

  secret_id     = aws_secretsmanager_secret.users_api_mongodb.id
  secret_string = var.users_api_mongodb_connection_uri
}

output "users_api_mongodb_secret_arn" {
  description = "ARN of the users-api MongoDB connection secret"
  value       = aws_secretsmanager_secret.users_api_mongodb.arn
}

output "users_api_mongodb_secret_name" {
  description = "Name of the users-api MongoDB connection secret"
  value       = aws_secretsmanager_secret.users_api_mongodb.name
}