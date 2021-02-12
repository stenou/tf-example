resource "aws_security_group" "web" {
  name        = "web"
  description = "Allow web inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "web"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16", "11.0.0.0/16"]
  }

  ingress {
      from_port   = 1234
      to_port     = 1234
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "C" {
  ami           = data.aws_ami.aws-linux.id
  instance_type = "t3.nano"
  associate_public_ip_address = true
  iam_instance_profile = aws_iam_instance_profile.this.name
  key_name = var.ssh_key
  vpc_security_group_ids = [ aws_security_group.web.id ]

  subnet_id = module.vpc.public_subnets[2]

  user_data = <<-EOF
#! bin/bash
sudo yum install nginx -y
sed -i 's|listen       80|listen       1234|' /etc/nginx/nginx.conf
sed -i 's|listen       [::]:80|listen       [::]:1234|' /etc/nginx/nginx.conf
sudo service nginx restart
EOF
}