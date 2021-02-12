Public Subnet - Has an internet gateway. Instances in this subnet can be access from the internet
Private Subnet - Has a NAT gateway.  Instances in this subnet have access to the internet but can't be accessed from the internet
Intra Subnet - Does not have access to the internet

The default security group for the vpcs has port 22 and 80 open to any traffic that can access it

Instance A is in the private subnet.  It can access the internet but can't be accessed from the internet
Instance B is in the intra subnet.  It can't access the internet.  It can access s3 through an s3 endpoint
Instance C is in the public subnet.  It can be access from the internet and has access to the internet