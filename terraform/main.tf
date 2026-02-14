provider "aws" {
  region = "ap-south-1" # Mumbai
}

# 1. Automatically find the latest Ubuntu 22.04 AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# 2. Create Security Group for Fashion App
resource "aws_security_group" "fashion_app_sg" {
  name        = "fashion_website_sg_v3"
  description = "Allow SSH and Fashion App traffic"

  # SSH Access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Frontend Port
  ingress {
    from_port   = 5173
    to_port     = 5173
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Admin Panel Port
  ingress {
    from_port   = 5174
    to_port     = 5174
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Backend API Port
  ingress {
    from_port   = 4000
    to_port     = 4000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 3. Generate SSH Key Pair Automatically
resource "tls_private_key" "fashion_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "fashion_app_key" {
  key_name   = "fashion-app-key-mumbai"
  public_key = tls_private_key.fashion_key.public_key_openssh
}

# Save the private key to a local .pem file for Jenkins/SSH
resource "local_file" "fashion_private_key" {
  content  = tls_private_key.fashion_key.private_key_pem
  filename = "fashion-app-key.pem"
  file_permission = "0400" # Sets correct permissions automatically
}

# 4. Create the EC2 Instance
resource "aws_instance" "fashion_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  
  key_name               = aws_key_pair.fashion_app_key.key_name
  vpc_security_group_ids = [aws_security_group.fashion_app_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install -y docker.io
              sudo systemctl start docker
              sudo systemctl enable docker
              sudo usermod -aG docker ubuntu
              
              # Install Docker Compose (V2)
              sudo mkdir -p /usr/local/lib/docker/cli-plugins/
              sudo curl -SL https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-linux-x86_64 -o /usr/local/lib/docker/cli-plugins/docker-compose
              sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
              
              # Standard docker-compose command support
              sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
              sudo chmod +x /usr/local/bin/docker-compose
              EOF

  tags = {
    Name = "FashionWebsiteServer"
  }
}

# 5. Output the Public IP
output "fashion_server_ip" {
  value = aws_instance.fashion_server.public_ip
}