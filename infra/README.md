## Bastion Host Sécurisé sur AWS avec Terraform
Ce projet déploie une infrastructure AWS sécurisée comprenant un Bastion Host et un serveur applicatif dans un subnet privé, avec :

Une VPC segmentée (public + privé)

Un Bastion Host restreint en SSH à votre IP

Un serveur applicatif accessible en SSH seulement depuis le bastion

IMDSv2 forcé sur toutes les instances

Gestion déclarative et reproductible via Terraform
