# ---------------------------------------------------
# IAM ROLE FOR GENERAL EC2 INSTANCE SSM ACCESS
# ---------------------------------------------------

# IAM Role for EC2 Instance Connect and SSM
# This role is meant for non-ECS EC2 instances that need SSM access
resource "aws_iam_role" "ssm_instance_role" {
  name = "${local.name}-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

# Attach SSM Policy to General EC2 Role
resource "aws_iam_role_policy_attachment" "ssm_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.ssm_instance_role.name
}

# IAM Instance Profile for General EC2 Instances
resource "aws_iam_instance_profile" "ssm_profile" {
  name = "${local.name}-ssm-profile"
  role = aws_iam_role.ssm_instance_role.name
}

# ---------------------------------------------------
# IAM ROLE FOR FARGATE TASK EXECUTION
# ---------------------------------------------------

# IAM Role for ECS Fargate Task Execution
# This role is used by Fargate tasks to pull images and access logs
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${local.name}-ecs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

# Attach ECS Execution Policy to Fargate Tasks
# Grants permissions to retrieve container images and send logs
resource "aws_iam_role_policy_attachment" "ecs_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
