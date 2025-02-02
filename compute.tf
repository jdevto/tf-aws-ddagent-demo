# Create EC2 Instance with Datadog Agent installed
resource "aws_instance" "instance1" {
  ami                    = data.aws_ami.amzn2023.id
  instance_type          = "t3.micro"
  subnet_id              = module.vpc.private_subnets[0]
  iam_instance_profile   = aws_iam_instance_profile.ssm_profile.name
  vpc_security_group_ids = [aws_security_group.ec2_ice.id]

  user_data = templatefile("${path.module}/external/instance1-cloud-init.yaml", {
    dd_api_key = var.dd_api_key
  })

  tags = {
    Name = "${local.name}-instance1"
  }
}

# Create EC2 Instance with Datadog Agent installed using Docker Compose
resource "aws_instance" "instance2" {
  ami                    = data.aws_ami.amzn2023.id
  instance_type          = "t3a.medium"
  subnet_id              = module.vpc.private_subnets[0]
  iam_instance_profile   = aws_iam_instance_profile.ssm_profile.name
  vpc_security_group_ids = [aws_security_group.ec2_ice.id]

  user_data = templatefile("${path.module}/external/instance2-cloud-init.yaml", {
    dd_api_key = var.dd_api_key
  })

  tags = {
    Name = "${local.name}-instance2"
  }
}
