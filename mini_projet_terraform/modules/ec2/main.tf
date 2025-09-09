# Data source pour l'AMI Ubuntu Jammy
data "aws_ami" "my_ubuntu_ami" {
  most_recent = true
  owners      = ["099720109477"]
  
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Data source pour le VPC par défaut
data "aws_vpc" "default" {
  default = true
}

# Data source pour la subnet dans la AZ
data "aws_subnet" "selected" {
  vpc_id            = data.aws_vpc.default.id
  availability_zone = var.AZ
}

resource "aws_instance" "mini-projet-ec2" {
  ami               = data.aws_ami.my_ubuntu_ami.id
  instance_type     = var.instance_type
  key_name          = var.ssh_key
  availability_zone = var.AZ
  subnet_id         = data.aws_subnet.selected.id
  vpc_security_group_ids = var.sg_ids

  # Connection pour le provisioner
  connection {
    type        = "ssh"
    user        = var.user
    private_key = file(var.private_key_path)
    host        = self.public_ip
    timeout     = "15m"
  }

  # Provisioner pour installer Docker, Docker Compose et Jenkins
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common",
      
      # Installation de Docker
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg",
      "echo \"deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
      "sudo apt-get update -y",
      "sudo apt-get install -y docker-ce docker-ce-cli containerd.io",
      
      # Installation de Docker Compose
      "sudo curl -L \"https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)\" -o /usr/local/bin/docker-compose",
      "sudo chmod +x /usr/local/bin/docker-compose",
      
      # Ajout de l'utilisateur au groupe Docker
      "sudo usermod -aG docker ${var.user}",
      
      # Création du répertoire Jenkins
      "mkdir -p /home/ubuntu/jenkins",
      
      # Création du docker-compose.yml pour Jenkins
      "cat > /home/ubuntu/jenkins/docker-compose.yml << 'EOL'",
      "version: '3.8'",
      "services:",
      "  jenkins:",
      "    image: jenkins/jenkins:lts-jdk17",
      "    privileged: true",
      "    user: root",
      "    ports:",
      "      - 8080:8080",
      "      - 50000:50000",
      "    container_name: jenkins",
      "    volumes:",
      "      - /home/ubuntu/jenkins:/var/jenkins_home",
      "      - /var/run/docker.sock:/var/run/docker.sock",
      "    environment:",
      "      - JAVA_OPTS=-Djenkins.install.runSetupWizard=false",
      "    restart: unless-stopped",
      "EOL",
      
      # Correction des permissions
      "sudo chown -R ubuntu:ubuntu /home/ubuntu/jenkins",
      "sudo chmod -R 755 /home/ubuntu/jenkins",
      
      # Démarrage de Jenkins avec Docker Compose
      "cd /home/ubuntu/jenkins && sudo docker-compose up -d",
      
      # Attente que le conteneur soit démarré
      "sleep 10",
      "sudo docker ps"
    ]
  }

  tags = {
    Name = "${var.maintainer}-ec2"
  }
}