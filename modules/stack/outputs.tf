output "vpc" {
    value = module.vpc
}

output "public_ip" {
    value = aws_instance.C.public_ip
}

