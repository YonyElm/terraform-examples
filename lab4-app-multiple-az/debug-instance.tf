# ##########################################
# ## Remote connection using SSH
# ##########################################
# # SSH connectinocan be done only when IGW is connected, and can't be done behind NAT

# # Key Name will be prompted for user input when deploying
# variable "key_name" {}

# resource "tls_private_key" "ec2_ssh_key" {
#   algorithm = "RSA"
#   rsa_bits  = 4096
# }

# resource "aws_key_pair" "generated_key" {
#   key_name   = var.key_name
#   public_key = tls_private_key.ec2_ssh_key.public_key_openssh
# }

# resource "local_file" "private_key" {
#     content  = tls_private_key.ec2_ssh_key.private_key_pem
#     filename = "${var.key_name}.pem"
# }

# output "private_key" {
#   value     = tls_private_key.ec2_ssh_key.private_key_pem
#   sensitive = true
# }

# ##########################################
# ## Setting up EC2 instance
# ##########################################

# resource "aws_instance" "debug_instance" {
#   ami           = data.aws_ami.amazon_linux_2.id
#   instance_type = "t3.micro"
#   key_name      = aws_key_pair.generated_key.key_name

#   vpc_security_group_ids  = ["${aws_security_group.app_sg.id}"]
#   subnet_id               = aws_subnet.public1.id

#   # Adding a bash script that instance will start with (not reccomended)
#   user_data = <<EOF
#     #!/bin/bash
#     sudo yum install -y git wget gcc openssl-devel curl
#     EOF

#   tags = {
#     Name = "Debug Instance"
#   }
# }

# # Printing
# output "instance_public_ips" {
#   value = aws_instance.debug_instance.*.public_ip
# }