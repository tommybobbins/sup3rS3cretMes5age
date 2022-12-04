# Load balancer for the instances
resource "aws_lb_target_group" "supersecret" {
  depends_on = [
    aws_instance.supersecret,
  ]
  name        = "supersecret-targetgroup"
  port        = 443
  protocol    = "HTTPS"
  vpc_id      = module.vpc.vpc_id
  target_type = "instance"
}

resource "aws_lb_target_group_attachment" "supersecret" {
  depends_on = [
    aws_lb_target_group.supersecret
  ]
  target_group_arn = aws_lb_target_group.supersecret.arn
  target_id        = aws_instance.supersecret.id
  port             = 443
}

resource "aws_lb" "supersecret" {
  depends_on = [
    aws_lb_target_group.supersecret
  ]
  name               = "supersecret-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ec2-sg.id]
  subnets            = module.vpc.public_subnets
}

resource "aws_lb_listener" "front_end" {
  depends_on = [
    aws_lb.supersecret
  ]
  load_balancer_arn = aws_lb.supersecret.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn = data.aws_acm_certificate.supersecret.arn
  ssl_policy        = "ELBSecurityPolicy-2016-08"


  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.supersecret.arn
  }
}
