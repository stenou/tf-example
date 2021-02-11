provider aws {
    profile="personal"
    region = "us-west-2"
}

module stack1 {
    source = "./modules/stack"

    name = "first-vpc"
    cidr = "10.0.0.0/16"

    azs             = ["us-west-2a", "us-west-2b", "us-west-2c"]
    private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
    public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
    intra_subnets   = ["10.0.201.0/24", "10.0.202.0/24", "10.0.203.0/24"]

    ssh_key = "personal"
    iam_policy = data.aws_iam_policy_document.s3_readwrite.json
}

module stack2 {
    source = "./modules/stack"

    name = "second-vpc"
    cidr = "11.0.0.0/16"

    azs             = ["us-west-2a", "us-west-2b", "us-west-2c"]
    private_subnets = ["11.0.1.0/24", "11.0.2.0/24", "11.0.3.0/24"]
    public_subnets  = ["11.0.101.0/24", "11.0.102.0/24", "11.0.103.0/24"]
    intra_subnets   = ["11.0.201.0/24", "11.0.202.0/24", "11.0.203.0/24"]

    ssh_key = "personal"
    iam_policy = data.aws_iam_policy_document.s3_readwrite.json
}

resource "aws_vpc_peering_connection" "default" {
  peer_vpc_id   = module.stack1.vpc_id
  vpc_id        = module.stack2.vpc_id
  auto_accept   = true
}

# Create routes from requestor to acceptor
resource "aws_route" "requestor_public" {
  count                     = length(module.stack1.vpc.public_route_table_ids)
  route_table_id            = element(module.stack1.vpc.public_route_table_ids, count.index)
  destination_cidr_block = module.stack2.vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.default.id
}

# Create routes from acceptor to requestor
resource "aws_route" "acceptor_public" {
  count                     = length(module.stack2.vpc.public_route_table_ids)
  route_table_id            = element(module.stack2.vpc.public_route_table_ids, count.index)
  destination_cidr_block = module.stack1.vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.default.id
}

# Create routes from requestor to acceptor
resource "aws_route" "requestor_private" {
  count                     = length(module.stack1.vpc.private_route_table_ids)
  route_table_id            = element(module.stack1.vpc.private_route_table_ids, count.index)
  destination_cidr_block = module.stack2.vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.default.id
}

# Create routes from acceptor to requestor
resource "aws_route" "acceptor_private" {
  count                     = length(module.stack2.vpc.private_route_table_ids)
  route_table_id            = element(module.stack2.vpc.private_route_table_ids, count.index)
  destination_cidr_block = module.stack1.vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.default.id
}

# Create routes from requestor to acceptor
resource "aws_route" "requestor_intra" {
  count                     = length(module.stack1.vpc.intra_route_table_ids)
  route_table_id            = element(module.stack1.vpc.intra_route_table_ids, count.index)
  destination_cidr_block = module.stack2.vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.default.id
}

# Create routes from acceptor to requestor
resource "aws_route" "acceptor_intra" {
  count                     = length(module.stack2.vpc.intra_route_table_ids)
  route_table_id            = element(module.stack2.vpc.intra_route_table_ids, count.index)
  destination_cidr_block = module.stack1.vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.default.id
}