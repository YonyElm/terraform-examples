## LB infrastructure

# Choosing the
resource "aws_lb_target_group" "app_tg" {
  name          = "App-Target-Group"
  target_type   = "instance"
  vpc_id        = aws_vpc.vpc1.id
  port          = 80
  protocol      = "HTTP"

  # These are not recommended values, leave blank for recommended values
  health_check { 
    healthy_threshold = 2         # Expect for 2 requests in a row return positive results
    interval          = 10        # Check every 10 seconds for health
  }
}

resource "aws_lb" "lb1" {
  name               = "App-Load-Balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = [aws_subnet.public1.id, aws_subnet.public2.id]

  # enable_deletion_protection = true

  tags = {
    Environment = "production"
  }
}

# Binding load balancer with targetgroup
resource "aws_lb_listener" "lb1_listener1" {
  load_balancer_arn = aws_lb.lb1.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

output "load_balancer_url"{
  value = aws_lb.lb1.dns_name
}