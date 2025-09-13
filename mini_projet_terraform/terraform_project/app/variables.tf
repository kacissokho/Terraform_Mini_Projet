variable "private_key_path" {
  description = "Chemin vers la clé privée correspondant à key_name sur l'EC2"
  type        = string
  default     = ".secrets/terraform-key.pem"
}

variable "domain_name" {
  description = "Nom de domaine pointant vers l'IP publique (laisser vide si aucun)"
  type        = string
  default     = ""
}

variable "jenkins_image" {
  description = "Image Docker Jenkins"
  type        = string
  default     = "jenkins/jenkins:lts-jdk17"
}

