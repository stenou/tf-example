resource "aws_iam_role" "this" {
  assume_role_policy = data.aws_iam_policy_document.ec2.json
}

data "aws_iam_policy_document" "ec2" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "default" {
  role   = aws_iam_role.this.id
  policy = var.iam_policy
}

resource "aws_iam_instance_profile" "this" {
  role = aws_iam_role.this.name
}