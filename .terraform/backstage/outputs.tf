output "ecs_services" {
  value     = module.ecs.services
  sensitive = true
}

output "ecs_frontend_sg_id" {
  value = module.ecs.services["ecsdemo-frontend"].security_group_id
}

output "rds_dns_endpoint" {
  value = module.db.db_instance_endpoint
}
