resource "aws_vpc" "vpc2" {
  provider = aws.peer
  cidr_block = "10.5.0.0/16"

  tags = {
    Name = "VPC2"
  }
}

resource "aws_subnet" "sub3" {
  provider          = aws.peer
  vpc_id            = aws_vpc.vpc2.id
  cidr_block        = "10.5.0.0/23"
  map_public_ip_on_launch = false
  availability_zone = data.aws_availability_zones.available2.names[1]

  tags = {
    Name = "Private3"
  }
}

resource "aws_subnet" "sub4" {
  provider          = aws.peer
  vpc_id            = aws_vpc.vpc2.id
  cidr_block        = "10.5.2.0/23"
  map_public_ip_on_launch = false
  availability_zone = data.aws_availability_zones.available2.names[2]

  tags = {
    Name = "Private4"
  }
}

###############################################################

resource "aws_route_table" "rt2" {
  provider    = aws.peer
  vpc_id      = aws_vpc.vpc2.id

  tags = {
    Name = "VPC2 Route Table"
  }
}

# Link routing table with specific subnet
resource "aws_route_table_association" "sub3_rt2" {
  provider        = aws.peer
  subnet_id       = aws_subnet.sub3.id
  route_table_id  = aws_route_table.rt2.id
}

# Link routing table with specific subnet
resource "aws_route_table_association" "sub4_rt2" {
  provider        = aws.peer
  subnet_id       = aws_subnet.sub4.id
  route_table_id  = aws_route_table.rt2.id
}

###############################################################

resource "aws_security_group" "db_sg" {
  provider    = aws.peer
  name        = "DB-SG"
  description = "Allow DB Access"
  vpc_id      = aws_vpc.vpc2.id

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

# Accepting VPC peering request once arrives
resource "aws_vpc_peering_connection_accepter" "vpc-peering-ack" {
  provider                  = aws.peer
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc-peering-req.id
  auto_accept               = true

  tags = {
    Name = "VPC2 Peer Acception To VPC1"
  }
}

# Adding peering record to rt2
resource "aws_route" "rt2-peering-route" {
  provider                  = aws.peer
  route_table_id            = aws_route_table.rt2.id
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc-peering-req.id
  destination_cidr_block    = aws_vpc.vpc1.cidr_block
}
