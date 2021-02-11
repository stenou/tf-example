resource "aws_vpc" "this" {
  cidr_block = var.cidr

  enable_dns_hostnames = true
  enable_dns_support = true
}

###################
# Internet Gateway
###################
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      "Name" = format("%s", var.name)
    }
  )
}

################
# Publiс routes
################
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      "Name" = format("%s-public", var.name)
    }
  )
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id

  timeouts {
    create = "5m"
  }
}

#################
# Private routes
# There are as many routing tables as the number of NAT gateways
#################
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      "Name" = "${var.name}-private"
    },
    var.tags,
  )
}

#################
# Intra routes
#################
resource "aws_route_table" "intra" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      "Name" = "${var.name}-intra"
    },
    var.tags,
  )
}

################
# Public subnet
################
resource "aws_subnet" "public" {
  count = length(var.public_subnets)

  vpc_id                          = aws_vpc.this.id
  cidr_block                      = element(var.public_subnets, count.index)
  availability_zone               = element(var.azs, count.index)
  map_public_ip_on_launch         = false

  tags = merge(
    {
      "Name" = format(
        "%s-public-%s",
        var.name,
        element(var.azs, count.index),
      )
    },
    var.tags
  )
}

#################
# Private subnet
#################
resource "aws_subnet" "private" {
  count = length(var.private_subnets)

  vpc_id                          = aws_vpc.this.id
  cidr_block                      = var.private_subnets[count.index]
  availability_zone               = element(var.azs, count.index)
  map_public_ip_on_launch = false

  tags = merge(
    {
      "Name" = format(
        "%s-private-%s",
        var.name,
        element(var.azs, count.index),
      )
    },
    var.tags
  )
}

#####################################################
# intra subnets - private subnet without NAT gateway
#####################################################
resource "aws_subnet" "intra" {
  count = length(var.intra_subnets) > 0 ? length(var.intra_subnets) : 0

  vpc_id                          = aws_vpc.this.id
  cidr_block                      = var.intra_subnets[count.index]
  availability_zone               = element(var.azs, count.index)

  tags = merge(
    {
      "Name" = format(
        "%s-intra-%s",
        var.name,
        element(var.azs, count.index),
      )
    },
    var.tags
  )
}

/* Elastic IP for NAT */
resource "aws_eip" "nat_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.this]
}

/* NAT */
resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id = element(aws_subnet.public.*.id, 0)

  tags = merge(
    {
      "Name" = format(
        "%s-%s",
        var.name,
        element(var.azs, 0),
      )
    },
    var.tags
  )

  depends_on = [aws_internet_gateway.this]
}

resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this.id

  timeouts {
    create = "5m"
  }
}

data "aws_vpc_endpoint_service" "s3" {
  service_type = "Gateway"
  service      = "s3"
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.this.id
  service_name      = data.aws_vpc_endpoint_service.s3.service_name
  vpc_endpoint_type = "Gateway"
}

##########################
# Route table association
##########################
resource aws_vpc_endpoint_route_table_association "s3" {
  route_table_id = aws_route_table.intra.id
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnets)

  subnet_id = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnets)

  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "intra" {
  count = length(var.intra_subnets)

  subnet_id      = element(aws_subnet.intra.*.id, count.index)
  route_table_id = aws_route_table.intra.id
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.this.id

  ingress {
    protocol  = -1
    from_port = 0
    to_port   = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}