resource "aws_route_table" "aws-routeA" {
  vpc_id = aws_vpc.aws-vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.aws-natgwA.id
  }
  tags = {
    Name = "${var.aws_prefix}-routeA-${random_string.aws-suffix.result}"
  }
}

resource "aws_route_table" "aws-routeB" {
  vpc_id = aws_vpc.aws-vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.aws-natgwB.id
  }
  tags = {
    Name = "${var.aws_prefix}-routeB-${random_string.aws-suffix.result}"
  }
}

resource "aws_subnet" "aws-private-subnet-A" {
  vpc_id            = aws_vpc.aws-vpc.id
  availability_zone = data.aws_availability_zones.aws-azs.names[var.aws_az]
  cidr_block        = var.private_subnet_A_cidr
  tags = {
    Name = "${var.aws_prefix}-private-subnet-A-${random_string.aws-suffix.result}"
    "kubernetes.io/cluster/${var.aws_prefix}-eks-cluster-${random_string.aws-suffix.result}" = "shared"
  }
  depends_on = [aws_nat_gateway.aws-natgwA]
}

resource "aws_subnet" "aws-private-subnet-B" {
  vpc_id            = aws_vpc.aws-vpc.id
  availability_zone = data.aws_availability_zones.aws-azs.names[var.aws_az + 1]
  cidr_block        = var.private_subnet_B_cidr
  tags = {
    Name = "${var.aws_prefix}-private-subnet-B-${random_string.aws-suffix.result}"
    "kubernetes.io/cluster/${var.aws_prefix}-eks-cluster-${random_string.aws-suffix.result}" = "shared"
  }
  depends_on = [aws_nat_gateway.aws-natgwB]
}

resource "aws_route_table_association" "aws-route-private-subnet-A" {
  subnet_id      = aws_subnet.aws-private-subnet-A.id
  route_table_id = aws_route_table.aws-routeA.id
}

resource "aws_route_table_association" "aws-route-private-subnet-B" {
  subnet_id      = aws_subnet.aws-private-subnet-B.id
  route_table_id = aws_route_table.aws-routeB.id
}
