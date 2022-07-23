resource "aws_vpc" "vpc1" {
  cidr_block = "10.0.0.0/20"
  enable_dns_hostnames = true

  tags = {
    Name = "VPC1"
  }
}

resource "aws_subnet" "public1" {
  vpc_id     = aws_vpc.vpc1.id
  cidr_block = "10.0.0.0/24"  
  availability_zone = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "Public1"
  }
}

resource "aws_subnet" "public2" {
  vpc_id     = aws_vpc.vpc1.id
  cidr_block = "10.0.1.0/24"
  availability_zone = data.aws_availability_zones.available.names[2]
  map_public_ip_on_launch = true

  tags = {
    Name = "Public2"
  }
}

resource "aws_subnet" "private1" {
  vpc_id     = aws_vpc.vpc1.id
  cidr_block = "10.0.2.0/23"
  availability_zone = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = false

  tags = {
    Name = "Private1"
  }
}

resource "aws_subnet" "private2" {
  vpc_id     = aws_vpc.vpc1.id
  cidr_block = "10.0.4.0/23"
  availability_zone = data.aws_availability_zones.available.names[2]
  map_public_ip_on_launch = false

  tags = {
    Name = "Private2"
  }
}


######################################################################


resource "aws_internet_gateway" "igw1" {
  vpc_id = aws_vpc.vpc1.id

  tags = {
    Name = "Internet Gateway"
  }
}


resource "aws_route_table" "public_rt1" {
  vpc_id = aws_vpc.vpc1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw1.id
  }

  tags = {
    Name = "VPC1 Public Routung Table"
  }
}

# Link routing table with specific subnet
resource "aws_route_table_association" "igw1_for_public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public_rt1.id
}

# Link routing table with specific subnet
resource "aws_route_table_association" "igw1_for_public2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public_rt1.id
}

#########

resource "aws_eip" "elastic_ip1" {
  vpc                       = true

  tags = {
    Name = "Elastic IP1"
  }
}

resource "aws_nat_gateway" "ngw1" {
  allocation_id   = aws_eip.elastic_ip1.id
  subnet_id       = aws_subnet.public1.id

  tags = {
    Name = "NAT Gateway1"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw1]
}

resource "aws_route_table" "private_rt1" {
  vpc_id = aws_vpc.vpc1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw1.id
  }

  tags = {
    Name = "VPC1 Private Routung Table1"
  }
}

# Link routing table with specific subnet
resource "aws_route_table_association" "nat1_for_private2" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private_rt1.id
}

##################

resource "aws_eip" "elastic_ip2" {
  vpc                       = true

  tags = {
    Name = "Elastic IP2"
  }
}

resource "aws_nat_gateway" "ngw2" {
  allocation_id   = aws_eip.elastic_ip2.id
  subnet_id       = aws_subnet.public2.id

  tags = {
    Name = "NAT Gateway2"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw1]
}

resource "aws_route_table" "private_rt2" {
  vpc_id = aws_vpc.vpc1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw2.id
  }

  tags = {
    Name = "VPC1 Private Routung Table 2"
  }
}

# Link routing table with specific subnet
resource "aws_route_table_association" "nat2_for_private2" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.private_rt1.id
}
