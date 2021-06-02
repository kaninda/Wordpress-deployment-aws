//EC2
resource "aws_instance" "ec2_instance_wordpress" {
  ami           = lookup(var.ami_id, var.region)
  instance_type = var.instance_type_ec2
  # Public Subnet assign to instance
  subnet_id = aws_subnet.subnet_private_1.id

  # Security group assign to instance
  vpc_security_group_ids      = [aws_security_group.allow_ssh_http.id]
  associate_public_ip_address = false

  # key name
  key_name = "admin_ec2"
  tags = {
    Name        = "terraform_ec2_tp7"
    Environment = "development"
    Project     = "TP7"
  }
}

output "public_ip_ec2" {
  value = aws_instance.ec2_instance_wordpress.public_ip
}

// RDS
resource "aws_db_subnet_group" "db_subnet_group" {
  name        = "db-subnet-group"
  description = "Terraform example RDS subnet group"
  subnet_ids  = [aws_subnet.subnet_private_1.id, aws_subnet.subnet_private_2.id]
}

resource "aws_db_instance" "db_instance_mysql" {
  identifier                = "databaseaka"
  allocated_storage         = 10
  engine                    = "mysql"
  engine_version            = "5.6.35"
  instance_class            = "db.t2.micro"
  name                      = var.database_name
  username                  = var.database_user
  password                  = var.database_password
  db_subnet_group_name      = aws_db_subnet_group.db_subnet_group.id
  vpc_security_group_ids    = [aws_security_group.rds_security_group.id]
  parameter_group_name      = aws_db_parameter_group.parameter_group.name
  skip_final_snapshot       = true
  final_snapshot_identifier = "Ignore"
}


output "end_point" {
  value = aws_db_instance.db_instance_mysql.endpoint
}

resource "aws_db_parameter_group" "parameter_group" {
  name        = "akagroup"
  description = "aka parameter group for mysql5.7"
  family      = "mysql5.6"
  parameter {
    name  = "character_set_server"
    value = "utf8"
  }
  parameter {
    name  = "character_set_client"
    value = "utf8"
  }
}

// NAT INSTANCE  -- BASTION

resource "aws_instance" "nat" {
  ami           = lookup(var.ami_id, var.region)
  instance_type = var.instance_type_ec2
  # Public Subnet assign to instance
  subnet_id = aws_subnet.subnet_public.id

  vpc_security_group_ids      = [aws_security_group.nat.id]
  associate_public_ip_address = true
  source_dest_check           = false

  # key name
  key_name = "admin_ec2"
  tags = {
    Name        = "terraform_bastion_tp7"
    Environment = "development"
    Project     = "TP7"
  }
}

// 

output "public_ip_bastion" {
  value = aws_instance.nat.public_ip
}

//APPLICATION LOAd BALANCER
resource "aws_alb" "alb" {
  name            = "aka-alb"
  security_groups = [aws_security_group.alb.id]
  subnets         = [aws_subnet.subnet_private_1.id, aws_subnet.subnet_private_2.id]
}

resource "aws_alb_target_group" "group" {
  name        = "aka-alb-target"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.aws_aka.id
  target_type = "instance"

  health_check {
    path = "/index.php"
    port = 80
  }
}

resource "aws_alb_listener" "listener_http" {
  load_balancer_arn = aws_alb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.group.arn
    type             = "forward"
  }
}



