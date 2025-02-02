# Datadog Agent Installation Demo

This Terraform project demonstrates different methods of installing and running the Datadog Agent in various AWS environments.

## Installation Methods

### 1. Install on EC2

- Deploys an EC2 instance with the Datadog Agent installed.
- Uses Amazon Linux 2023 AMI.
- Installs the agent via user data.

### 2. Install in Docker as a Container in EC2

- Deploys an EC2 instance running the Datadog Agent inside a Docker container.
- Uses Docker Compose for setup.

### 3. Deploy on ECS Fargate

- Runs the Datadog Agent as a sidecar container in an ECS Fargate task.
- Includes logging and monitoring configuration.

### 4. Deploy on ECS Cluster (Classic)

- Deploys the Datadog Agent as a daemon service in an ECS cluster running on EC2 instances.
- Integrated with CloudWatch Logs.

## Deployment Instructions

1. Clone the repository.
2. Set up Terraform backend configuration.
3. Run `terraform init` to initialize the project.
4. Execute `terraform apply` to provision the resources.

## Cleanup

To destroy the environment, run:

```sh
terraform destroy
```

Review all provisioned resources carefully before executing to prevent unintended deletions.

## License

This project is licensed under the MIT License. See the LICENSE file for details.
