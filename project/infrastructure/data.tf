data "aws_key_pair" "keypair_ssh" {
  key_name = "keypair-wordpress"
}



data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}