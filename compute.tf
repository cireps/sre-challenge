
data "aws_ami" "redhat" {
  most_recent = true
  filter {
    name   = "name"
    values = ["redhat/images/hvm-ssd/redhat-9-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["309956199498"] # Red Hat
}

resource "aws_instance" "web" {
  count         = 3
  ami           = data.aws_ami.redhat.id
  instance_type = "t2.micro"
  subnet_id     = element([aws_subnet.private1.id, aws_subnet.private2.id, aws_subnet.private3.id], count.index)

  vpc_security_group_ids = [aws_security_group.ec2_sg.id] #Updating security group to ec2_sg

  root_block_device {
    volume_size = 20
  }

  tags = {
    Name = "web-${count.index}"
  }
}

resource "aws_lb" "alb" {
  name               = "my-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_http.id] # Updating security group to allow_http
  subnets            = [aws_subnet.public1.id, aws_subnet.public2.id, aws_subnet.public3.id]
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.front_end.arn
  }
}

resource "aws_lb_target_group" "front_end" {
  name     = "tf-example-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    enabled             = true
    interval            = 30
    path                = "/"
    port                = "traffic-port"
    timeout             = 3
    healthy_threshold   = 3
    unhealthy_threshold = 3
    protocol            = "HTTP"
    matcher             = "200-399"
  }
}

resource "aws_lb_target_group_attachment" "web" {
  count            = 3
  target_group_arn = aws_lb_target_group.front_end.arn
  target_id        = element(aws_instance.web.*.id, count.index)
  port             = 80
}
