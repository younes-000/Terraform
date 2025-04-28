## Bastion Host Sécurisé sur AWS avec Terraform
Ce projet déploie une infrastructure AWS sécurisée comprenant un Bastion Host et un serveur applicatif dans un subnet privé, avec :

Une VPC segmentée (public + privé)

Un Bastion Host restreint en SSH à votre IP

Un serveur applicatif accessible en SSH seulement depuis le bastion

IMDSv2 forcé sur toutes les instances

Gestion déclarative et reproductible via Terraform

## Prérequis
AWS CLI installé et configuré

Terraform (v1.0+) installé

Une paire de clés SSH générée localement (ssh-keygen)

Un compte AWS avec les droits nécessaires pour créer VPC, EC2, IAM, etc.

## Structure 

infra/
├─ provider.tf
├─ variables.tf
├─ main.tf
├─ outputs.tf
└─ modules/
   └─ vpc/
   └─ bastion/
   └─ backend/
