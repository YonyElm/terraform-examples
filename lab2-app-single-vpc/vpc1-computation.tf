##########################################
## Remote connection using SSH
##########################################
# SSH connectinocan be done only when IGW is connected, and can't be done behind NAT

# Key Name will be prompted for user input when deploying
variable "key_name" {}

resource "tls_private_key" "ec2_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.key_name
  public_key = tls_private_key.ec2_ssh_key.public_key_openssh
}

resource "local_file" "private_key" {
    content  = tls_private_key.ec2_ssh_key.private_key_pem
    filename = "${var.key_name}.pem"
}

output "private_key" {
  value     = tls_private_key.ec2_ssh_key.private_key_pem
  sensitive = true
}

##########################################
## Setting up EC2 instance
##########################################

# Set an AMI Image - "amazon_linux_2" machine - Allowing reproducable usage of this machine when new machines are needed
data "aws_ami" "amazon_linux_2" {
  most_recent  = true
  owners       = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_instance" "web_app" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t3.micro"
  key_name      = aws_key_pair.generated_key.key_name

  vpc_security_group_ids  = ["${aws_security_group.app_sg.id}"]
  subnet_id               = aws_subnet.sub1.id

  # Adding a bash script that instance will start with (not reccomended)
  user_data = <<EOF
    #!/bin/bash
    # Install Docker
    sudo yum install -y git
    sudo amazon-linux-extras install docker -y
    sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    # Download Lab files (git is preinstalled on machine)
    git clone https://github.com/YonyElm/app-simple-stack.git
    # Turn on docker
    sudo service docker start
    # Build and run container
    cd app-simple-stack
    sudo /usr/local/bin/docker-compose build
    sudo /usr/local/bin/docker-compose up
    EOF

  tags = {
    Name = "App Server"
  }
}

# Printing
output "instance_public_ips" {
  value = aws_instance.web_app.*.public_ip
}