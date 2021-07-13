// SECURITY GROUP

resource "aws_security_group" "sgEc2" {
  name   = "sgEc2"
  vpc_id = aws_vpc.aws_aka.id

  ingress {
    # SSH Port 22 allowed from any IP
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.subnet_public_adr_1]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }
  tags = {
    Name        = "sgEc2"
    Environment = "development"
    Project     = "TP7"
  }

}

resource "aws_security_group" "rds_security_group" {
  name        = "aws-rds-sg"
  description = "RDS (terraform-managed)"
  vpc_id      = aws_vpc.aws_aka.id


  ingress {
    # TCP Port for private sg
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name        = "rds_sg"
    Environment = "development"
    Project     = "TP7"
  }
}


resource "aws_security_group" "alb" {
  name        = "terraform_alb_security_group"
  description = "Terraform load balancer security group"
  vpc_id      = aws_vpc.aws_aka.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "alb_sg"
    Environment = "development"
    Project     = "TP7"
  }

}

resource "aws_security_group" "bastion_sg" {
  name   = "bastion-security-group"
  vpc_id = aws_vpc.aws_aka.id

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name        = "bastion_sg"
    Environment = "development"
    Project     = "TP7"
  }
}

