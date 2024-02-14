# Define auto-scaling group
resource "aws_autoscaling_group" "example" {
  name                     = "example-asg"
  launch_configuration    = aws_launch_configuration.example1.name
  min_size                 = 2
  max_size                 = 4
  force_delete             = true
  depends_on               = [aws_lb.custom]
  desired_capacity         = 2
  health_check_type        = "EC2"
  target_group_arns      = ["${aws_lb_target_group.custom.arn}"]
  launch_configuration   = aws_launch_configuration.example1.name
  vpc_zone_identifier      = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
  health_check_grace_period = 30
  
}

resource "aws_launch_configuration" "example1" {
  name = "custom-example-launchconfig"
  # Ubuntu Server 18.04 LTS (HVM), SSD Volume Type in ap-south-01
  image_id        = "ami-0c7217cdde317cfec"
  instance_type   = "t2.micro"
  associate_public_ip_address = true
  security_groups = [aws_security_group.public_subnet_sg_1.id, aws_security_group.public_subnet_sg_2.id]

  root_block_device {
    volume_type = "gp2"
    volume_size = 10
    encrypted   = true
  }

  ebs_block_device {
    device_name = "/dev/sdf"
    volume_type = "gp2"
    volume_size = 5
    encrypted   = true
  }

  # Whenever using a launch configuration with an auto scaling group, you must set below
  lifecycle {
    create_before_destroy = true
  }
    user_data = filebase64("${path.module}/init_webserver.sh")
}
