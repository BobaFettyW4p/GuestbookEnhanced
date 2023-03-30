data "template_file" "guestbook" {
  template = file("./templates/guestbook_ecs_template.json")
  vars = {
    aws_ecr_repository = aws_ecr_repository.guestbook.repository_url
    tag                = "latest"
    app_port           = 80
  }
}

resource "aws_ecs_cluster" "guestbook" {
  name = "guestbook"
}

resource "aws_vpc" "guestbook" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
}

resource "aws_ecs_task_definition" "guestbook" {
  family                   = "guestbook"
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.guestbook_execution_role.arn
  cpu                      = 256
  memory                   = 2048
  requires_compatibilities = ["FARGATE"]
  container_definitions    = data.template_file.guestbook.rendered
  tags = {
    Environment = "Production"
    Application = "Guestbook"
  }
}

resource "aws_ecs_service" "guestbook" {
  name            = "guestbook"
  cluster         = aws_ecs_cluster.guestbook.id
  task_definition = aws_ecs_task_definition.guestbook.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = data.aws_subnet_ids.default.ids
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.guestbook.arn
    container_name   = "guestbook"
    container_port   = 5000
  }

  depends_on = [
    aws_lb_listener.https_forward, aws_iam_role_policy_attachment.guestbook
  ]

  tags = {
    Environment = "Production"
    Application = "Guestbook"
  }
}

