resource "aws_security_group" "lb_sg" {
  name        = "LB-SG"
  description = "Allow Load Balancer Access"
  vpc_id      = aws_vpc.vpc1.id

  # Inbound Rules - Type HTTP, Source all Ipv4
  ingress {
    description      = "HTTP from IPV4"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  # Inbound Rules - Type HTTPS, Source all Ipv4
  ingress {
    description      = "HTTPS from IPV4"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  # Outbound Rules - open for all Traffic Ip6/Ip4
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "LB-SG"
  }
}

resource "aws_security_group" "app_sg" {
  name        = "App-SG"
  description = "Allow Web Access"
  vpc_id      = aws_vpc.vpc1.id

  # Inbound Rules - HTTP Traffic from load balancer
  ingress {
    description      = "Traffic from load balancer"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    security_groups  = [aws_security_group.lb_sg.id]
  }

  # Inbound Rules - SSH traffic for debug & remote connection
  ingress {
    description     = "SSH traffic"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  # Outbound Rules - open for all Traffic Ip6/Ip4
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "App-SG"
  }
}

resource "aws_security_group" "db_sg" {
  name        = "DB-SG"
  description = "Allow DB Access"
  vpc_id      = aws_vpc.vpc1.id

  # InBound Rules - Type MySQL/Aurora, Source App-SG
  ingress {
    description      = "Classic MySQL Protocol"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    security_groups  = [aws_security_group.app_sg.id]
  }

  # Outbound Rules - open for all Traffic Ip6/Ip4
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "DB-SG"
  }
}