## VPC
The default security group for the vpc has port 22 and 80 open to any traffic that can access it

## Subnets
Public Subnet - Instances in this subnet can be accessed from/to the internet through the internet gateway

Private Subnet - Instances in this subnet can access the internet through a NAT gateway

Intra Subnet - Does not have access to the internet

## Instances
Instance A is in the private subnet.

Instance B is in the intra subnet.  It can access s3 through an s3 endpoint

Instance C is in the public subnet.  It is assigned a public ip address. It has its own security group that opens port 1234 in addition to 80 from the other subnets.