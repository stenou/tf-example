resource "aws_vpc_peering_connection" "default" {
  peer_vpc_id   = module.stack1.vpc.vpc_id
  vpc_id        = module.stack2.vpc.vpc_id
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

# Create routes from requestor to acceptor
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

# Create routes from requestor to acceptor
resource "aws_route" "acceptor_intra" {
  count                     = length(module.stack2.vpc.intra_route_table_ids)
  route_table_id            = element(module.stack2.vpc.intra_route_table_ids, count.index)
  destination_cidr_block = module.stack1.vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.default.id
}