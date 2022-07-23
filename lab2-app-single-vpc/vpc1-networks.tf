resource "aws_vpc" "vpc1" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "VPC1"
  }
}

# Support EC2
resource "aws_subnet" "sub1" {
  vpc_id     = aws_vpc.vpc1.id
  cidr_block = "10.0.0.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public1"
  }
}

# Support DB Multizone
resource "aws_subnet" "sub2" {
  vpc_id     = aws_vpc.vpc1.id
  cidr_block = "10.0.2.0/23"
  map_public_ip_on_launch = false
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "Private1"
  }
}

# Support DB Multizone
resource "aws_subnet" "sub3" {
  vpc_id     = aws_vpc.vpc1.id
  cidr_block = "10.0.4.0/23"
  map_public_ip_on_launch = false
  availability_zone = data.aws_availability_zones.available.names[2]

  tags = {
    Name = "Private2"
  }
}

# Must have in order to enable connection to the internet or remote access to EC2
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc1.id

  tags = {
    Name = "Internet Gateway"
  }
}

###############################################################

resource "aws_route_table" "rt1" {
  vpc_id = aws_vpc.vpc1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "VPC1 Route Table"
  }
}

# Link routing table with specific subnet
resource "aws_route_table_association" "sub1_rt1" {
  subnet_id      = aws_subnet.sub1.id
  route_table_id = aws_route_table.rt1.id
}

###############################################################

resource "aws_security_group" "app_sg" {
  name        = "App-SG"
  description = "Allow Web Access"
  vpc_id      = aws_vpc.vpc1.id

  # Inbound Rules - Type HTTP, Source all Ipv4
  ingress {
    description      = "HTTP from IPV4"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  # Inbound Rules - SSH traffic for remote connection
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


###############################################################