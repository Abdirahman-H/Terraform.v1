provider "aws" {
  region = "eu-west-2" # London
}

# Get the latest Amazon Linux 2023 (Kernel 6.1) AMI in eu-west-2
data "aws_ssm_parameter" "al2023_kernel61" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64"
}

# Launch EC2 instance in the default VPC
resource "aws_instance" "free_tier_ec2" {
  ami           = data.aws_ssm_parameter.al2023_kernel61.value
  instance_type = "t2.micro" # Free Tier eligible
  key_name      = "my-keypair" # Replace with your existing keypair name
  tags = {
    Name = "free-tier-ec2-london"
  }
}

# Output the public IP after apply
output "public_ip" {
  value = aws_instance.free_tier_ec2.public_ip
}
