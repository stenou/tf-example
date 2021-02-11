resource "aws_instance" "B" {
  ami           = data.aws_ami.aws-linux.id
  instance_type = "t3.nano"
  iam_instance_profile = aws_iam_instance_profile.this.name
  key_name = var.ssh_key

  subnet_id = module.vpc.intra_subnets[1]
}