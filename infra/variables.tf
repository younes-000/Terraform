variable "aws_region" {  # ici je defini la région AWS
  description = "Région AWS"
  type        = string
  default     = "eu-west-1"
}

variable "vpc_cidr" { # ici he defini le CIDR du VPC
  description = "CIDR du VPC"
  type        = string
  default     = "10.0.0.0/16" # exemple pour eu-west-3
}

variable "public_subnet_cidr" { # ici je defini le CIDR du subnet public
  # le subnet public est celui qui a une passerelle internet
  description = "CIDR du subnet public"
  type        = string
  default     = "10.0.1.0/24" # exemple pour eu-west-3
  # le CIDR du subnet public doit être dans le même bloc CIDR que le VPC
}

variable "private_subnet_cidr" { # ici je defini le CIDR du subnet privé
  # le subnet privé est celui qui n'a pas de passerelle internet
  description = "CIDR du subnet privé"
  type        = string
  default     = "10.0.2.0/24" # exemple pour eu-west-3
  # le CIDR du subnet privé doit être dans le même bloc CIDR que le VPC
}

variable "mon_ip" { # ici je defini mon IP publique
  description = "mon ip avec /32 pour SSH" # car je veux restreindre l'accès SSH à mon IP publique
  type        = string
}

variable "bastion_ami" {
  description = "AMI pour le Bastion (Amazon Linux 2)" # ici je defini l'AMI pour le Bastion
  type        = string
  default     = "ami-0e449927258d45bc4"  # ca sera une AMI Amazon Linux 2
}

variable "bastion_type" { # ici je defini le type d'instance pour le Bastion
  description = "Type d’instance pour le Bastion"
  type        = string
  default     = "t3.micro" # c'est le type d'instance le moins cher
}

variable "public_key_path" { # ici je defini le chemin vers la clé SSH publique
  description = "Chemin vers la clé SSH publique"
  type        = string
  default     = "public_key.pub" # le fichier ou je vais mettre ma clé publique
}

