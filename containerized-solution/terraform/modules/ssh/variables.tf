variable "project_name" {
  description = "Name of the project for resource naming"
  type        = string
  default     = "docker-swarm"
}

variable "private_key_path" {
  description = "Path where the private key will be saved"
  type        = string
  default     = "~/.ssh/docker-swarm-key.pem"
}