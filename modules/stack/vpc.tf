module vpc {
    source = "../vpc"
    cidr = var.cidr

    azs             = var.azs
    private_subnets = var.private_subnets
    public_subnets  = var.public_subnets
    intra_subnets   = var.intra_subnets
}