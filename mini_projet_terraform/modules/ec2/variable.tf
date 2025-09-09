variable "maintainer" {

  type    = string

  default ="mini_projet_jenkins"

}

variable "instance_type" {

  type    = string

  default ="t3.micro"

}

variable "ssh_key" {

  type    = string

  default ="terraform-key"

}


variable "sg_ids" {
  description = "Liste des IDs des security groups à associer à l'EC2"
  type        = list(string)
  default     = []
}



variable "pubic_ip" {

  type    = string

  default ="NULL"

}

variable "AZ" {

  type    = string

  default ="us-east-1b"

}

variable "user" {

  type    = string

  default ="ubuntu"

}

variable "private_key_path" {
  type    = string
  default = ".secrets/terraform-key.pem"
}