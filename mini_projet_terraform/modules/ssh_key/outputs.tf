output "key_name" {
  description = "Nom de la paire de clés AWS"
  value       = aws_key_pair.this.key_name
}

output "public_key" {
  description = "Clé publique générée"
  value       = tls_private_key.this.public_key_openssh
  sensitive   = true
}

output "private_key_pem" {
  description = "Clé privée au format PEM"
  value       = tls_private_key.this.private_key_pem
  sensitive   = true
}

output "private_key_file" {
  description = "Chemin du fichier de la clé privée"
  value       = "${var.output_directory}/${var.key_name}.pem"
}