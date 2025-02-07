# Log group for Datadog Agent in Fargate
resource "aws_cloudwatch_log_group" "ddagent_fargate" {
  name              = "/${local.name}-fargate/ecs/service/ddagent"
  retention_in_days = 1

  lifecycle {
    prevent_destroy = false
  }
}

# Log group for Web Application in Fargate
resource "aws_cloudwatch_log_group" "webapp_fargate" {
  name              = "/${local.name}-fargate/ecs/service/webapp"
  retention_in_days = 1

  lifecycle {
    prevent_destroy = false
  }
}


# Log group for Datadog Agent in classic ECS (EC2)
resource "aws_cloudwatch_log_group" "ddagent_classic" {
  name              = "/${local.name}-classic/ecs/service/ddagent"
  retention_in_days = 1

  lifecycle {
    prevent_destroy = false
  }
}

# Log group for Cloudwatch Agent in classic ECS (EC2)
resource "aws_cloudwatch_log_group" "cwagent_classic" {
  name              = "/${local.name}-classic/ecs/service/cwagent"
  retention_in_days = 1

  lifecycle {
    prevent_destroy = false
  }
}
