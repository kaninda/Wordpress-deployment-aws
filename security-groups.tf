// SECURITY GROUP
resource "aws_security_group" "allow_ssh_http" {
  name                   = "allow-SSH-http"
  description            = "Allow SSH inbound traffic"
  vpc_id                 = aws_vpc.aws_aka.id
  revoke_rules_on_delete = true

  ingress {
    # SSH Port 22 allowed from any IP
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    # HTTP port 80 from any IP
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 443
    to_port     = 443
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "sg_ec2"
    Environment = "development"
    Project     = "TP7"
  }

}

resource "aws_security_group" "rds_security_group" {
  name        = "aws-rds-sg"
  description = "RDS (terraform-managed)"
  vpc_id      = aws_vpc.aws_aka.id


  ingress {
    # SSH Port 22 allowed from any IP
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.allow_ssh_http.id]
  }

  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name        = "rds_sg"
    Environment = "development"
    Project     = "TP7"
  }
}
