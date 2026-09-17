resource "aws_secretsmanager_secret" "auth_api_token_key" {
  name                    = "${local.project}/auth-api/token-key"
  description             = "JWT signing key (TOKEN_KEY) used by auth-api"
  recovery_window_in_days = 7

  tags = local.tags
}

variable "auth_api_token_key" {
  description = "Token key for auth-api. When empty, the secret is created without a value."
  type        = string
  sensitive   = true
  default     = ""
}

resource "aws_secretsmanager_secret_version" "auth_api_token_key" {
  count = var.auth_api_token_key != "" ? 1 : 0

  secret_id     = aws_secretsmanager_secret.auth_api_token_key.id
  secret_string = var.auth_api_token_key
}

resource "aws_secretsmanager_secret" "users_api_mongodb" {
  name                    = "${local.project}/users-api/mongodb-connection-uri"
  description             = "MongoDB connection string (MONGODB_CONNECTION_URI) used by users-api"
  recovery_window_in_days = 7

  tags = local.tags
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

resource "aws_secretsmanager_secret" "tasks_api_mongodb" {
  name                    = "${local.project}/tasks-api/mongodb-connection-uri"
  description             = "MongoDB connection string (MONGODB_CONNECTION_URI) used by tasks-api"
  recovery_window_in_days = 7

  tags = local.tags
}

variable "tasks_api_mongodb_connection_uri" {
  description = "MongoDB connection URI for tasks-api. When empty, the secret is created without a value."
  type        = string
  sensitive   = true
  default     = ""
}

resource "aws_secretsmanager_secret_version" "tasks_api_mongodb" {
  count = var.tasks_api_mongodb_connection_uri != "" ? 1 : 0

  secret_id     = aws_secretsmanager_secret.tasks_api_mongodb.id
  secret_string = var.tasks_api_mongodb_connection_uri
}

output "auth_api_token_key_secret_arn" {
  description = "ARN of the auth-api TOKEN_KEY secret"
  value       = aws_secretsmanager_secret.auth_api_token_key.arn
}

output "auth_api_token_key_secret_name" {
  description = "Name of the auth-api TOKEN_KEY secret"
  value       = aws_secretsmanager_secret.auth_api_token_key.name
}

output "users_api_mongodb_secret_arn" {
  description = "ARN of the users-api MongoDB connection secret"
  value       = aws_secretsmanager_secret.users_api_mongodb.arn
}

output "users_api_mongodb_secret_name" {
  description = "Name of the users-api MongoDB connection secret"
  value       = aws_secretsmanager_secret.users_api_mongodb.name
}

output "tasks_api_mongodb_secret_arn" {
  description = "ARN of the tasks-api MongoDB connection secret"
  value       = aws_secretsmanager_secret.tasks_api_mongodb.arn
}

output "tasks_api_mongodb_secret_name" {
  description = "Name of the tasks-api MongoDB connection secret"
  value       = aws_secretsmanager_secret.tasks_api_mongodb.name
}
