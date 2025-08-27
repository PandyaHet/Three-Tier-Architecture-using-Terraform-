data "aws_availability_zones" "available" {}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "three-tier-vpc"
  }
}

resource "aws_subnet" "public_web" {
  count                    = 2
  vpc_id                   = aws_vpc.main.id
  cidr_block               = var.public_subnet_cidrs[count.index]
  availability_zone        = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch  = true

  tags = {
    Name = "Public-Web-Subnet-AZ-${count.index + 1}"
    Tier = "Web"
    AZ   = data.aws_availability_zones.available.names[count.index]
  }
}

resource "aws_subnet" "private_app" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_app_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "Private-App-Subnet-AZ-${count.index + 1}"
    Tier = "App"
    AZ   = data.aws_availability_zones.available.names[count.index]
  }
}

resource "aws_subnet" "private_db" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_db_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "Private-DB-Subnet-AZ-${count.index + 1}"
    Tier = "DB"
    AZ   = data.aws_availability_zones.available.names[count.index]
  }
}

# INTERNET GATEWAY
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "three-tier-igw"
  }
}

# ELASTIC IPs for NAT Gateways
resource "aws_eip" "nat_eip" {
  count  = 2
  domain = "vpc"

  tags = {
    Name = "nat-eip-az-${count.index + 1}"
  }
}

# NAT Gateways
resource "aws_nat_gateway" "nat" {
  count         = 2
  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id     = aws_subnet.public_web[count.index].id

  tags = {
    Name = "nat-gateway-az-${count.index + 1}"
  }
}

# PUBLIC ROUTE TABLE
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_assoc" {
  count          = 2
  subnet_id      = aws_subnet.public_web[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

# PRIVATE ROUTE TABLES
resource "aws_route_table" "private_rt" {
  count  = 2
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "private-route-table-az-${count.index + 1}"
  }
}

resource "aws_route" "private_nat" {
  count                  = 2
  route_table_id         = aws_route_table.private_rt[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat[count.index].id
}

resource "aws_route_table_association" "private_app_assoc" {
  count          = 2
  subnet_id      = aws_subnet.private_app[count.index].id
  route_table_id = aws_route_table.private_rt[count.index].id
}

resource "aws_route_table_association" "private_db_assoc" {
  count          = 2
  subnet_id      = aws_subnet.private_db[count.index].id
  route_table_id = aws_route_table.private_rt[count.index].id
}

# SECURITY GROUP: ELB
resource "aws_security_group" "elb_sg" {
  name        = "elb-sg"
  description = "Allow HTTP from your IP"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow HTTP from your IP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.your_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Public-ELB-SG"
  }
}

# SECURITY GROUP: Web Tier
resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow HTTP from ELB and your IP"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Allow HTTP from ELB SG"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.elb_sg.id]
  }

  ingress {
    description = "Allow HTTP from your IP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.your_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Web-Tier-SG"
  }
}

# SECURITY GROUP: Internal ELB
resource "aws_security_group" "internal_elb_sg" {
  name        = "internal-elb-sg"
  description = "Allow HTTP from Web Tier SG"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Allow HTTP from Web SG"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Internal-ELB-SG"
  }
}

# SECURITY GROUP: App Tier
resource "aws_security_group" "app_sg" {
  name        = "app-sg"
  description = "Allow TCP 4000 from Internal ELB and your IP"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Allow TCP 4000 from Internal ELB SG"
    from_port       = 4000
    to_port         = 4000
    protocol        = "tcp"
    security_groups = [aws_security_group.internal_elb_sg.id]
  }

  ingress {
    description = "Allow TCP 4000 from your IP"
    from_port   = 4000
    to_port     = 4000
    protocol    = "tcp"
    cidr_blocks = [var.your_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "App-Tier-SG"
  }
}

# SECURITY GROUP: DB Tier
resource "aws_security_group" "db_sg" {
  name        = "db-sg"
  description = "Allow MySQL from App Tier SG"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Allow MySQL from App SG"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "DB-Tier-SG"
  }
}