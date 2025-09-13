resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "this" {
  key_name   = "${var.key_name}-${substr(md5(tls_private_key.this.public_key_openssh), 0, 8)}"
  public_key = tls_private_key.this.public_key_openssh

  tags = {
    Name        = var.key_name
    Maintainer  = var.maintainer
    Environment = var.environment
  }
}

resource "local_sensitive_file" "private_key" {
  content         = tls_private_key.this.private_key_pem
  filename        = "${var.output_directory}/${var.key_name}.pem"
  file_permission = "0600"
}