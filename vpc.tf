# VPC Module
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.18.1"

  azs                  = local.azs
  cidr                 = local.vpc_cidr
  enable_dns_hostnames = local.enable_dns_hostnames
  name                 = local.name
  private_subnets      = local.private_subnets
  public_subnets       = local.public_subnets

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    name = local.name
  }
}

# Create Security Group for EC2 Instances
resource "aws_security_group" "ec2_ice" {
  name        = "${local.name}-ec2-ice"
  description = "Allow traffic from EC2 Instance Connect Endpoint"
  vpc_id      = module.vpc.vpc_id

  # Allow SSH only from EC2 Instance Connect Endpoint
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${data.http.my_public_ip.response_body}/32"]
  }

  # Allow HTTPS traffic for EC2 Instance Connect (Required)
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name}-ec2-ice"
  }
}

# Create Security Group for Webapp
resource "aws_security_group" "webapp" {
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create Security Group for ECS Classic
resource "aws_security_group" "ecs" {
  name   = "${local.name}-ecs"
  vpc_id = module.vpc.vpc_id

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "allow all incoming traffic"
    from_port   = 0
    protocol    = -1
    self        = "false"
    to_port     = 0
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "allow all outbound traffic"
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }

  tags = {
    Name = "${local.name}-ecs"
  }
}

# Create EC2 Instance Connect Endpoint
resource "aws_ec2_instance_connect_endpoint" "example" {
  subnet_id          = module.vpc.private_subnets[0]
  security_group_ids = [aws_security_group.ec2_ice.id]

  tags = {
    Name = local.name
  }
}
