terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.65.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.5"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.4.1"
    }
  }
  required_version = "1.12.2"
}

provider "aws" {
  region                   = "us-east-1"
  shared_credentials_files = [".secrets/credentials"]
  profile                  = "mini_projet_jenkins"
}

# Création de la paire de clés dynamique
module "ssh_key" {
  source           = "../../modules/ssh_key"
  key_name         = "jenkins-key"
  maintainer       = "mini_projet_jenkins"
  environment      = "production"
  output_directory = "${path.module}/.secrets"
}

# VPC par défaut
data "aws_vpc" "default" {
  default = true
}

module "sg" {
  source = "../../modules/sg"
  vpc_id = data.aws_vpc.default.id
}

# Récupère l'ID du SG créé par le module (à partir de son nom)
data "aws_security_group" "sg_by_name" {
  depends_on = [module.sg]
  name       = module.sg.output_sg_name
  vpc_id     = data.aws_vpc.default.id
}

module "ebs" {
  source    = "../../modules/ebs"
  disk_size = 5
  maintainer = "mini_projet_jenkins"
}

module "eip" {
  source = "../../modules/eip"
}

module "ec2" {
  source           = "../../modules/ec2"
  instance_type    = "t3.micro"
  sg_ids           = [data.aws_security_group.sg_by_name.id]
  ssh_key_name     = module.ssh_key.key_name
  private_key_path = module.ssh_key.private_key_file
  maintainer       = "mini_projet_jenkins"
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = module.ec2.output_ec2_id
  allocation_id = module.eip.output_eip_id

  depends_on = [module.ec2]
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = module.ebs.output_id_volume
  instance_id = module.ec2.output_ec2_id

  depends_on = [module.ec2]
}

resource "local_file" "jenkins_info" {
  filename = "jenkins_ec2.txt"
  content  = <<-EOT
Jenkins Server Information:
Public IP: ${module.eip.output_eip}
Public DNS: ${module.ec2.output_ec2_public_dns}
Jenkins URL: http://${module.eip.output_eip}:8080
Jenkins URL: http://${module.ec2.output_ec2_public_dns}:8080

SSH Connection:
ssh -i "${module.ssh_key.private_key_file}" ubuntu@${module.eip.output_eip}

To get initial admin password:
sudo docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
EOT

  depends_on = [module.ec2, aws_eip_association.eip_assoc]
}

# Output pour faciliter l'accès
output "ssh_connection_command" {
  description = "Commande SSH pour se connecter à l'instance"
  value       = "ssh -i \"${module.ssh_key.private_key_file}\" ubuntu@${module.eip.output_eip}"
}

output "jenkins_url" {
  description = "URL d'accès à Jenkins"
  value       = "http://${module.eip.output_eip}:8080"
}

output "private_key_path" {
  description = "Chemin vers la clé privée générée"
  value       = module.ssh_key.private_key_file
  sensitive   = true
}