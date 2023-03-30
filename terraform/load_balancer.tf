resource "aws_lb" "guestbook" {
  name_prefix        = "lb-"
  subnets            = data.aws_subnet_ids.default.ids
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb.id]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "https_forward" {
  load_balancer_arn = aws_lb.guestbook.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.guestbook.arn
  }
}

resource "aws_lb_target_group" "guestbook" {
  name_prefix = "gb-"
  port        = 5000
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id
  target_type = "ip"

  health_check {
    healthy_threshold   = "2"
    interval            = "300"
    protocol            = "HTTP"
    matcher             = "200-299"
    timeout             = "20"
    path                = "/"
    unhealthy_threshold = "2"
  }
  lifecycle {
    create_before_destroy = true
  }
}
