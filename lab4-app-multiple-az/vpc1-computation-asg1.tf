# Set an AMI Image - "amazon_linux_2" machine - Allowing reproducable usage of this machine when new machines are needed
data "aws_ami" "amazon_linux_2" {
  most_recent  = true
  owners       = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_launch_template" "launch_template1" {
  name          = "Launch-Template1"
  image_id      = data.aws_ami.amazon_linux_2.id
  instance_type = "t2.micro"
  # key_name      = aws_key_pair.generated_key.key_name # Used for debug in order to SSH to the instabce
  
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  instance_initiated_shutdown_behavior = "terminate"
  
  # Intance shopping options (finance) - This option good for Labs
  instance_market_options {
    market_type = "spot"
  }

  # monitoring {
  #   enabled = true
  # }

  # credit_specification {
  #   cpu_credits = "standard"
  # }

  # Adding a bash script that instance will start with
  user_data = filebase64("${path.module}/ec2-server.sh")

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "App Server"
    }
  }
}

resource "aws_autoscaling_group" "app_asg" {
  name = "App-ASG"
  desired_capacity          = 2
  max_size                  = 2
  min_size                  = 2
  health_check_grace_period = 200
  health_check_type         = "EC2"

  vpc_zone_identifier = [aws_subnet.private1.id, aws_subnet.private2.id]
  target_group_arns = [aws_lb_target_group.app_tg.arn]

  launch_template {
    id      = aws_launch_template.launch_template1.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "App Server - ASG"
    propagate_at_launch = true
  }
}