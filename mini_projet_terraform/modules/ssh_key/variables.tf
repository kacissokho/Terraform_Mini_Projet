variable "key_name" {
  description = "Nom de base pour la paire de clés"
  type        = string
  default     = "terraform-key"
}

variable "maintainer" {
  description = "Nom du mainteneur pour les tags"
  type        = string
  default     = "mini_projet_jenkins"
}

variable "environment" {
  description = "Environnement pour les tags"
  type        = string
  default     = "production"
}

variable "output_directory" {
  description = "Répertoire où sauvegarder la clé privée"
  type        = string
  default     = ".secrets"
}