# Create Target group

resource "aws_lb_target_group" "custom" {
  name       = "Demo-TargetGroup-custom"
  depends_on = [aws_vpc.example_vpc]
  port       = 80
  protocol   = "HTTP"
  vpc_id     = aws_vpc.example_vpc.id
  health_check {
    interval            = 70
    path                = "/index.html"
    port                = 80
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 30
    protocol            = "HTTP"
    matcher             = "200,202"
  }
}
# Create ALB

resource "aws_lb" "custom" {
  name               = "Demo-alb-custom"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.elb_sg.id]
  subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
}

# Create ALB Listener 

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.custom.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.custom.arn
  }
}

