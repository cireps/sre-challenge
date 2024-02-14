resource "aws_vpc" "main" {
    cidr_block = var.cidr_block
}

resource "aws_subnet" "public1" {
    vpc_id     = aws_vpc.main.id
    cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 8, 1)  
    map_public_ip_on_launch = true
}

resource "aws_subnet" "public2" {
    vpc_id     = aws_vpc.main.id
    cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 8, 2)  
    map_public_ip_on_launch = true
}

resource "aws_subnet" "public3" {
    vpc_id     = aws_vpc.main.id
    cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 8, 3)  
    map_public_ip_on_launch = true
}

resource "aws_subnet" "private1" {
    vpc_id     = aws_vpc.main.id
    cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 8, 4)  
}

resource "aws_subnet" "private2" {
    vpc_id     = aws_vpc.main.id
    cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 8, 5) 
}

resource "aws_subnet" "private3" {
    vpc_id     = aws_vpc.main.id
    cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 8, 6)  # Updated CIDR block using cidrsubnet function
}

resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow all inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}