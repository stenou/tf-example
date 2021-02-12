provider aws {
    region = "us-west-2"
}

resource "aws_s3_bucket" "s3" {
  bucket = "stenou-test"
  acl    = "private"

  versioning {
    enabled = true
  }
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