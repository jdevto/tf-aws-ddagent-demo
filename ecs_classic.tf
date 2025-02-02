module "ecs_cluster_classic" {
  source  = "tfstack/ecs-cluster-classic/aws"
  version = "1.0.2"

  cluster_name            = "${local.name}-classic"
  enable_cloudwatch_agent = true
  security_group_ids = [
    aws_security_group.ecs.id,
    aws_security_group.ec2_ice.id
  ]

  vpc = {
    id = module.vpc.vpc_id
    private_subnets = [
      for i, subnet in module.vpc.private_subnets :
      { id = subnet, cidr = module.vpc.private_subnets_cidr_blocks[i] }
    ]
  }

  # Auto Scaling Groups
  autoscaling_groups = [
    {
      name                  = "asg-1"
      min_size              = 1
      max_size              = 6
      desired_capacity      = 3
      image_id              = data.aws_ami.ecs_optimized.id
      instance_type         = "t3a.medium"
      ebs_optimized         = true
      protect_from_scale_in = false

      additional_iam_policies = [
        "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
      ]

      # Tags
      tag_specifications = [
        {
          resource_type = "instance"
          tags = {
            Environment = "production"
            Name        = "asg-1"
          }
        }
      ]

      # User Data
      user_data = templatefile("${path.module}/external/ecs.sh.tpl", {
        cluster_name = "${local.name}-classic"
      })
    }
  ]

  ecs_services = [
    {
      name                = "ddagent"
      scheduling_strategy = "DAEMON"
      cpu                 = "128"
      memory              = "256"

      execution_role_policies = [
        "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
      ]

      container_definitions = jsonencode([
        {
          name      = "datadog-agent"
          image     = "public.ecr.aws/datadog/agent:latest"
          cpu       = 128
          memory    = 256
          essential = true

          mountPoints = [
            { containerPath = "/etc/passwd", sourceVolume = "passwd", readOnly = true },
            { containerPath = "/var/run/docker.sock", sourceVolume = "docker_sock", readOnly = true },
            { containerPath = "/host/sys/fs/cgroup", sourceVolume = "cgroup", readOnly = true },
            { containerPath = "/host/proc/", sourceVolume = "proc", readOnly = true },
            { containerPath = "/sys/kernel/debug", sourceVolume = "debug" },
            { containerPath = "/host/etc/os-release", sourceVolume = "os_release", readOnly = true },
            { containerPath = "/etc/group", sourceVolume = "group", readOnly = true }
          ]

          environment = [
            { name = "DD_API_KEY", value = var.dd_api_key },
            { name = "DD_SITE", value = "datadoghq.com" },
            { name = "DD_PROCESS_AGENT_ENABLED", value = "true" },
            { name = "DD_ECS_COLLECT_RESOURCE_TAGS_EC2", value = "true" },
            { name = "DD_SYSTEM_PROBE_NETWORK_ENABLED", value = "true" },
            { name = "DD_TRACEROUTE_ENABLED", value = "true" },
            { name = "DD_NETWORK_PATH_CONNECTIONS_MONITORING_ENABLED", value = "true" }
          ]

          healthCheck = {
            command     = ["CMD-SHELL", "agent health"]
            interval    = 30
            timeout     = 5
            retries     = 3
            startPeriod = 15
          }

          linuxParameters = {
            capabilities = {
              add = [
                "NET_ADMIN",
                "NET_RAW",
                "SYS_ADMIN",
                "SYS_RESOURCE",
                "SYS_PTRACE",
                "NET_BROADCAST",
                "IPC_LOCK",
                "CHOWN"
              ]
              drop = []
            }
          }

          logConfiguration = {
            logDriver = "awslogs"
            options = {
              awslogs-group         = "/${local.name}-classic/ecs/service/ddagent"
              awslogs-region        = local.region
              awslogs-stream-prefix = "ecs"
            }
          }
        }
      ])

      volumes = [
        { name = "passwd", host_path = "/etc/passwd" },
        { name = "proc", host_path = "/proc/" },
        { name = "docker_sock", host_path = "/var/run/docker.sock" },
        { name = "cgroup", host_path = "/sys/fs/cgroup/" },
        { name = "debug", host_path = "/sys/kernel/debug" },
        { name = "os_release", host_path = "/etc/os-release" },
        { name = "group", host_path = "/etc/group" }
      ]
    }
  ]

  depends_on = [
    aws_cloudwatch_log_group.cwagent_classic,
    aws_cloudwatch_log_group.ddagent_classic
  ]
}
