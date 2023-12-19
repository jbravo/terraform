# VPCs
resource "aws_vpc" "vpc_a" {
  cidr_block = "10.100.0.0/16"
  tags = {
    Name = "vpc-a"
  }
}

resource "aws_vpc" "vpc_b" {
  cidr_block = "10.200.0.0/16"
  tags = {
    Name = "vpc-b"
  }
}

# Subnets
resource "aws_subnet" "vpc_a_subnet_public_1a" {
  vpc_id     = aws_vpc.vpc_a.id
  cidr_block = "10.100.0.0/24"
  tags = {
    Name = "vpc-a-subnet-public-1a"
  }  
}

resource "aws_subnet" "vpc_b_subnet_private_1a" {
  vpc_id     = aws_vpc.vpc_b.id
  cidr_block = "10.200.0.0/24"
  tags = {
    Name = "vpc-b-subnet-private-1a"
  }  
}

# IGs
resource "aws_internet_gateway" "vpc_a_igw" {
  vpc_id = aws_vpc.vpc_a.id
  tags = {
    Name = "vpc-a-igw"
  }
}

# VPC peering
resource "aws_vpc_peering_connection" "vpc_a_peer_vpc_b" {
  vpc_id        = aws_vpc.vpc_a.id
  peer_vpc_id   = aws_vpc.vpc_b.id
  tags = {
    Name = "vpc-a-peer-vpc-b"
  }  
}

resource "aws_vpc_peering_connection_accepter" "accept_peering" {
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_a_peer_vpc_b.id
  auto_accept               = true
}

# Route tables and subnet associations
resource "aws_route_table" "vpc_a_rt_public" {
  vpc_id   = aws_vpc.vpc_a.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc_a_igw.id
  }
  route {
      cidr_block                = "10.200.0.0/24"
      vpc_peering_connection_id = aws_vpc_peering_connection.vpc_a_peer_vpc_b.id
  }
  tags = {
    Name = "vpc-a-rt-public"
  }
}

resource "aws_main_route_table_association" "set-vpc-a-main-public-rt" {
  vpc_id         = aws_vpc.vpc_a.id
  route_table_id = aws_route_table.vpc_a_rt_public.id
}

resource "aws_route_table" "vpc_b_rt_private" {
  vpc_id   = aws_vpc.vpc_b.id
  route {
      cidr_block                = "10.100.0.0/24"
      vpc_peering_connection_id = aws_vpc_peering_connection.vpc_a_peer_vpc_b.id
  }
  tags = {
    Name = "vpc-b-rt-private"
  }
}

resource "aws_main_route_table_association" "set-peer-subnet-peer-public-rt" {
  vpc_id         = aws_vpc.vpc_b.id
  route_table_id = aws_route_table.vpc_b_rt_private.id
}

# Security Groups
resource "aws_security_group" "allow_vpc_a" {
  name           = "allow_vpc_a"
  description    = "Allow all inbound traffic"
  vpc_id         = aws_vpc.vpc_a.id
  ingress {
    description  = "Allow ssh connections from the internet"
    from_port    = 22
    to_port      = 22
    protocol     = "tcp"
    cidr_blocks  = [ "0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    description ="worldwide"
    cidr_blocks = ["0.0.0.0/0"]
  }  
  ingress {
    description  = "Allow ping from VPC-B"
    from_port    = -1
    to_port      = -1
    protocol     = "icmp"
    cidr_blocks  = ["10.200.0.0/24"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "allow_vpc_a"
  }
}

resource "aws_security_group" "allow_vpc_b" {
  name          = "allow_vpc_b"
  description   = "Allow ICPM inbound traffic from main"
  vpc_id        = aws_vpc.vpc_b.id
  ingress {
    description = "Allow ping from VPC-A"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["10.100.0.0/24"]
  }
  ingress {
    description = "Allow 22 from the EC2 public IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks =["10.100.0.0/24"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "allow_vpc_b"
  }
}