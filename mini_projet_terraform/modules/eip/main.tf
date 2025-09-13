resource "aws_eip" "my_eip" {
  domain = "vpc"
  
  tags = {
    Name = "my-eip"
  }
}
