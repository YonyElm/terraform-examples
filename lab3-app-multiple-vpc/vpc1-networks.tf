resource "aws_vpc" "vpc1" {
  provider = aws.main
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "VPC1"
  }
}

resource "aws_subnet" "sub1" {
  provider = aws.main
  vpc_id     = aws_vpc.vpc1.id
  cidr_block = "10.0.0.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public1"
  }
}

resource "aws_subnet" "sub2" {
  provider    = aws.main
  vpc_id      = aws_vpc.vpc1.id
  cidr_block  = "10.0.2.0/23"
  map_public_ip_on_launch = false

  tags = {
    Name = "Private1"
  }
}

resource "aws_internet_gateway" "igw" {
  provider  = aws.main
  vpc_id    = aws_vpc.vpc1.id

  tags = {
    Name = "Internet Gateway"
  }
}


###############################################################

resource "aws_route_table" "rt1" {
  provider  = aws.main
  vpc_id    = aws_vpc.vpc1.id

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
  provider        = aws.main
  subnet_id       = aws_subnet.sub1.id
  route_table_id  = aws_route_table.rt1.id
}

###############################################################

resource "aws_security_group" "app_sg" {
  provider    = aws.main
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


###############################################################

# Creating VPC peering request
resource "aws_vpc_peering_connection" "vpc-peering-req" {
  provider        = aws.main
  vpc_id          = aws_vpc.vpc1.id # Requester
  peer_vpc_id     = aws_vpc.vpc2.id # Accepter
  # peer_owner_id = # Accepter ARN number that is being used when running peering cross different VPC account
  
  # auto_accept   = true

  tags = {
    Name = "VPC1 Peer Request To VPC2"
  }
}

# Adding peering record to rt1
resource "aws_route" "rt1-peering-route" {
  provider                  = aws.main
  route_table_id            = aws_route_table.rt1.id
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc-peering-req.id
  destination_cidr_block    = aws_vpc.vpc2.cidr_block
}