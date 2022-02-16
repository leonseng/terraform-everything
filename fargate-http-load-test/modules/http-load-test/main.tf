resource "random_id" "id" {
  byte_length = 8
}

data "aws_region" "current" {}

data "aws_availability_zones" "local_az" {
  state = "available"
  filter {
    name   = "region-name"
    values = ["${data.aws_region.current.name}"]
  }
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "ab-dos-${random_id.id.hex}"
  cidr = "10.0.0.0/16"

  azs            = slice(data.aws_availability_zones.local_az.names, 0, 3)
  public_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  tags = {
    id = random_id.id.hex
  }
}

resource "aws_ecs_cluster" "ab_dos" {
  name = "ab-dos-cluster-${random_id.id.hex}"
}

resource "aws_ecs_task_definition" "ab_dos" {
  family                   = "ab-dos-${random_id.id.hex}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  container_definitions = jsonencode([
    {
      name  = "apache-benchmark"
      image = var.load_test_image

      command = [
        var.target,
        tostring(var.concurrency_per_container)
      ]
    }
  ])
}

resource "aws_ecs_service" "ab_dos" {
  name            = "ab-dos-${random_id.id.hex}"
  cluster         = aws_ecs_cluster.ab_dos.id
  task_definition = aws_ecs_task_definition.ab_dos.arn
  desired_count   = var.load_test_container_count
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = module.vpc.public_subnets
    assign_public_ip = true
  }
}
