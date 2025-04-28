output "bastion_public_ip" {
  description = "IP publique du Bastion"
  value       = aws_instance.bastion.public_ip
}

output "app_private_ip" {
  description = "IP privée de l’App Server"
  value       = aws_instance.app.private_ip
}
