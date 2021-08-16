resource "aws_route_table" "aws-routeAB" {
  vpc_id = aws_vpc.aws-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.aws-gw.id
  }
  tags = {
    Name = "${var.aws_prefix}-route1-${random_string.aws-suffix.result}"
  }
}

resource "aws_subnet" "aws-public-subnet-A" {
  vpc_id            = aws_vpc.aws-vpc.id
  availability_zone = data.aws_availability_zones.aws-azs.names[var.aws_az]
  cidr_block        = var.public_subnet_A_cidr
  tags = {
    Name = "${var.aws_prefix}-public-subnet-A-${random_string.aws-suffix.result}"
  }
  depends_on = [aws_internet_gateway.aws-gw]
}

resource "aws_subnet" "aws-public-subnet-B" {
  vpc_id            = aws_vpc.aws-vpc.id
  availability_zone = data.aws_availability_zones.aws-azs.names[var.aws_az + 1]
  cidr_block        = var.public_subnet_B_cidr
  tags = {
    Name = "${var.aws_prefix}-public-subnet-B-${random_string.aws-suffix.result}"
  }
  depends_on = [aws_internet_gateway.aws-gw]
}

resource "aws_route_table_association" "aws-route-public-subnet-A" {
  subnet_id      = aws_subnet.aws-public-subnet-A.id
  route_table_id = aws_route_table.aws-routeAB.id
}

resource "aws_route_table_association" "aws-route-public-subnet-B" {
  subnet_id      = aws_subnet.aws-public-subnet-B.id
  route_table_id = aws_route_table.aws-routeAB.id
}
