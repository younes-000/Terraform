provider "aws" {
  region = var.aws_region # ici je defini la région AWS"
}

# 1. VPC
resource "aws_vpc" "main" { # ici je defini le VPC
  cidr_block           = var.vpc_cidr # ici je defini le CIDR du VPC
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "tf-vpc_senyo" } # ici je defini le nom du VPC
}

# 2. Internet Gateway
resource "aws_internet_gateway" "igw" { # ici je defini la passerelle internet elle va permettre aux instances de communiquer avec internet
  vpc_id = aws_vpc.main.id # ici je lie la passerelle internet au VPC
  tags   = { Name = "tf-igw_senyo" }
}

# 3. Subnets
resource "aws_subnet" "public" { # ici je defini le subnet public
  vpc_id                  = aws_vpc.main.id # ici je lie le subnet public au VPC
  cidr_block              = var.public_subnet_cidr # ici je defini le CIDR du subnet public pas le privé 
  map_public_ip_on_launch = true # ici je dis que le subnet public va avoir une IP publique
  tags = { Name = "tf-public-subnet_senyo" }
}

resource "aws_subnet" "private" { # ici je defini le subnet privé
  vpc_id     = aws_vpc.main.id # ici je lie le subnet privé au VPC
  cidr_block = var.private_subnet_cidr # ici je defini le CIDR du subnet privé pas le public
  tags = { Name = "tf-private-subnet_senyo" }
}

# 4. Route Table publique 
resource "aws_route_table" "public_rt" { # ca permet de definir la table de routage publique et de la lier au subnet public
  vpc_id = aws_vpc.main.id # ici je lie la table de routage au VPC
  route {
    cidr_block = "0.0.0.0/0" # ici je dis que tout le trafic sortant va passer par la passerelle internet
    gateway_id = aws_internet_gateway.igw.id # ici je lie la passerelle internet à la table de routage
  }
  tags = { Name = "tf-public-rt_senyo" }
}

resource "aws_route_table_association" "public_assoc" { # ici je lie la table de routage au subnet public
  subnet_id      = aws_subnet.public.id # ici je lie le subnet public à la table de routage
  route_table_id = aws_route_table.public_rt.id # ici je lie la table de routage au subnet public
}

# 5. Key Pair SSH
resource "aws_key_pair" "bastion" { # ici je defini la clé SSH pour le Bastion
  key_name   = "bastion-key"  # ici je defini le nom de la clé SSH"
  public_key = file(var.public_key_path) # ici je lie la clé publique au fichier
}

# 6. Security Group Bastion
resource "aws_security_group" "bastion_sg" { # ici je defini le groupe de sécurité pour le Bastion
  name        = "bastion-sg_senyo"
  description = "Permet SSH depuis ma machine" 
  vpc_id      = aws_vpc.main.id # ici je lie le groupe de sécurité au VPC

  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.mon_ip] # ici je dis que le groupe de sécurité va autoriser le SSH depuis mon IP publique
  }

  egress { # ici je dis que le groupe de sécurité va autoriser tout le trafic sortant
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # -1 signifie tout le trafic
    cidr_blocks = ["0.0.0.0/0"] # ici je dis que le groupe de sécurité va autoriser tout le trafic sortant c'est à dire vers n'importe quelle adresse IP
  }

  tags = { Name = "tf-bastion-sg_senyo" }
}

# 7. Security Group Private (pour les App servers)
resource "aws_security_group" "private_sg" { # ici je defini le groupe de sécurité pour les serveurs d'application
  name        = "private-sg_senyo"
  description = "Autorise SSH depuis le Bastion"
  vpc_id      = aws_vpc.main.id # ici je lie le groupe de sécurité au VPC

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id] # ici je dis que le groupe de sécurité va autoriser le SSH depuis le groupe de sécurité du Bastion
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # ici je dis que le groupe de sécurité va autoriser tout le trafic sortant c'est à dire vers n'importe quelle adresse IP
  }

  tags = { Name = "tf-private-sg_senyo" }
}

# 8. IAM Role & Profile pour SSM
data "aws_iam_policy_document" "ssm_assume_role" { # ici je defini le document de politique IAM pour le rôle SSM
  statement {
    actions = ["sts:AssumeRole"] # ici je dis que le rôle va pouvoir assumer le rôle SSM
    principals {
      type        = "Service" # ici je dis que le rôle va être un service car il va être utilisé par un service AWS
      identifiers = ["ec2.amazonaws.com"] # ici je dis que le rôle va être utilisé par EC2
    }
  }
}

resource "aws_iam_role" "ssm_role" { # ici je defini le rôle IAM pour SSM
  name               = "bastion-ssm-role_senyo" # ici je defini le nom du rôle IAM
  assume_role_policy = data.aws_iam_policy_document.ssm_assume_role.json # ici je lie le document de politique IAM au rôle IAM
}

resource "aws_iam_role_policy_attachment" "ssm_attach" { # ici je lie la politique IAM au rôle IAM
  role       = aws_iam_role.ssm_role.name # ici je lie le rôle IAM à la politique IAM
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "bastion_profile" { # ici je defini le profil d'instance IAM pour le Bastion
  name = "bastion-ssm-profile_senyo" #    ici je defini le nom du profil d'instance IAM
  role = aws_iam_role.ssm_role.name # ici je lie le rôle IAM au profil d'instance IAM
}

data "aws_ami" "al2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}


# 9. Instance Bastion
resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.al2.id
  instance_type               = var.bastion_type
  subnet_id                   = aws_subnet.public.id
  key_name                    = aws_key_pair.bastion.key_name
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.bastion_profile.name
  associate_public_ip_address = true

  tags = { Name = "tf-bastion-host" }
}

resource "aws_instance" "app" {
  ami                    = data.aws_ami.al2.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.private_sg.id]
  key_name               = aws_key_pair.bastion.key_name

  tags = {
    Name = "tf-app-server_senyo"
  }
}
