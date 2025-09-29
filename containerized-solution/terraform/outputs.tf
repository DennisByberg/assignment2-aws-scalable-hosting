output "manager_public_ip" {
  description = "Public IP of the Swarm manager"
  value       = module.compute.manager_public_ip
}

output "load_balancer_dns" {
  description = "DNS name of the Load Balancer"
  value       = module.networking.alb_dns_name
}

output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group"
  value       = module.compute.autoscaling_group_name
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = module.storage.s3_bucket_id
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  value       = module.storage.dynamodb_table_name
}

output "app_urls" {
  description = "Application URLs"
  value = {
    nginx      = "http://${module.networking.alb_dns_name}"
    visualizer = "http://${module.networking.alb_dns_name}:8080"
    fastapi    = "http://${module.networking.alb_dns_name}:8001"
  }
}