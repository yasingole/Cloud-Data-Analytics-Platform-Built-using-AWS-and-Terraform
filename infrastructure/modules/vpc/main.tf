#VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

#IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
    Environment = var.environment
  }
}

#Public subnets
resource "aws_subnet" "public_subnet" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-subnet-${count.index + 1}"
    Environment = var.environment

  }
}

#Private app subnets
resource "aws_subnet" "private_app_subnet" {
  count                   = length(var.private_app_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_app_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false


  tags = {
    Name = "${var.project_name}-private-app-subnet-${count.index + 1}"
    Environment = var.environment
  }
}

#Private database subnets
resource "aws_subnet" "private_database_subnet" {
  count                   = length(var.private_db_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_db_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false


  tags = {
    Name = "${var.project_name}-private-databaseb-subnet-${count.index + 1}"
    Environment = var.environment
  }
}

#EIP
resource "aws_eip" "nat" {
  count  = var.create_nat_gateway ? 1 : 0

  tags = {
    Name = "${var.project_name}-nat-eip"
    Environment = var.environment
  }
}

#NGW

resource "aws_nat_gateway" "main" {
  count         = var.create_nat_gateway ? 1 : 0
  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public_subnet[0].id

  tags = {
    Name = "${var.project_name}-nat-gateway"
    Environment = var.environment
  }

  depends_on = [aws_internet_gateway.igw]
}

#Route tables
#Public RT
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.project_name}-public-route-table"
    Environment = var.environment
  }
}
#Private RT
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  dynamic "route" {
    for_each = var.create_nat_gateway ? [1] : [0]
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.main[0].id
    }
  }

  tags = {
    Name = "${var.project_name}-private-route-table"
    Environment = var.environment
  }
}

#Route table associations
#Public subnet associations
resource "aws_route_table_association" "public_association" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public.id
}

#Private app subnet associations
resource "aws_route_table_association" "private_app_association" {
  count          = length(var.private_app_subnet_cidrs)
  subnet_id      = aws_subnet.private_app_subnet[count.index].id
  route_table_id = aws_route_table.private.id
}

#Private database subnet associations
resource "aws_route_table_association" "private_db_association" {
  count          = length(var.private_db_subnet_cidrs)
  subnet_id      = aws_subnet.private_database_subnet[count.index].id
  route_table_id = aws_route_table.private.id
}
