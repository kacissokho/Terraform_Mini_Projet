output  "output_ec2_id" {

  value = aws_instance.mini-projet-ec2.id

}

output "output_ec2_AZ" {

  value = aws_instance.mini-projet-ec2.availability_zone

}

output "output_ec2_public_dns" {
  value = aws_instance.mini-projet-ec2.public_dns
}

output "output_ec2_public_ip" {
  value = aws_instance.mini-projet-ec2.public_ip
}