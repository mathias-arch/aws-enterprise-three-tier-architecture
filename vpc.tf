resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = { Name = "${var.project_name}-VPC" }
}

# Subredes Públicas
resource "aws_subnet" "pub_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  tags = { Name = "Subnet-Public-1" }
}

resource "aws_subnet" "pub_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true
  tags = { Name = "Subnet-Public-2" }
}

# Subredes Privadas App
resource "aws_subnet" "priv_app_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "us-east-1a"
  tags = { Name = "Subnet-Priv-App-1" }
}

resource "aws_subnet" "priv_app_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.12.0/24"
  availability_zone = "us-east-1b"
  tags = { Name = "Subnet-Priv-App-2" }
}

# Internet Gateway y NAT Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.pub_1.id
  depends_on    = [aws_internet_gateway.igw]
}

# Tablas de Rutas y Asociaciones (Simplificado)
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
}

resource "aws_route_table_association" "pub_assoc" {
  count          = 2
  subnet_id      = element([aws_subnet.pub_1.id, aws_subnet.pub_2.id], count.index)
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "priv_assoc" {
  count          = 2
  subnet_id      = element([aws_subnet.priv_app_1.id, aws_subnet.priv_app_2.id], count.index)
  route_table_id = aws_route_table.private_rt.id
}