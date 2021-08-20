
// VPC
resource "aws_vpc" "aws_aka" {
  cidr_block           = var.vpc_adr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  tags = {
    Name = var.vpc_name
  }
}

output "aws_vpc_id" {
  value = aws_vpc.aws_aka.id
}

// INTERNET GATEWAY
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.aws_aka.id

  tags = local.tags
}

//EIP
resource "aws_eip" "eip_nat" {
  vpc  = true
  tags = local.tags
}

// SUBNET-PUBLIC
resource "aws_subnet" "subnet_public_1" {
  cidr_block              = var.subnet_public_adr_1
  vpc_id                  = aws_vpc.aws_aka.id
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zone_a

  tags = {
    Name        = "subnet_public1"
    Environment = "development"
    Project     = "TP7"
  }
}

output "aws_subnet_public_1" {
  value = aws_subnet.subnet_public_1.id
}

resource "aws_subnet" "subnet_public_2" {
  cidr_block              = var.subnet_public_adr_2
  vpc_id                  = aws_vpc.aws_aka.id
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zone_b

  tags = {
    Name        = "subnet_public1"
    Environment = "development"
    Project     = "TP7"
  }
}

output "aws_subnet_public_2" {
  value = aws_subnet.subnet_public_2.id
}



resource "aws_key_pair" "admin_ec2" {
  key_name   = "admin_ec2"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC5/sVWlZwUmkAHp6+kRYGEGF/Ky22RDO4u44ljD/qK8gamx7zCzTOptGFavvnE0xPXSTMlfIWte85ppYWoZq+R32CgitrifGMm7MH+vCf4qtlmKMLWcNH7LzdbBxK55qJxkwBrpul09waGMa4GZ+6EtgaK0rIJNt6H+n2charlu8dbJNwvj40YO0b+5vRslnD65hm1wR7sRnALv65vz+HD7TiCGF1NbL/C4AogfxOrWJ+Tzs75E88R73XCa96/dMPFYOfJHwbofNp0VfX69ZeOi2TADxogMX7e+n2rVs/K7RiRTgYuL/f/1r+fGdcVHHGsWbE7ZpFtMdIPraCvv6u64fO06/yuH2WrQxLMuMUM6onK26tSXCIOOBgng81Hez4yP/B+XSc9XiIDZg3ezZ+TowSnZrvHzEllQsDrJvJOi8Q+e+X4KDnhYIfpmlaMvZYbHRBhpOAGuC3VAtP7yRy1jW3KteJWTKb119TXnT6HULUPLctNAFgMxD5HhcIonVk= vagrant@arnaud-vm"
}

output "aws_instance_id" {
  value = aws_instance.ec2_instance_wordpress.id
}


// ROUTE PUBLIC

resource "aws_route_table" "route_public" {
  vpc_id = aws_vpc.aws_aka.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = local.tags
}


resource "aws_route_table_association" "public_route_ass1" {
  subnet_id      = aws_subnet.subnet_public_1.id
  route_table_id = aws_route_table.route_public.id
}

resource "aws_route_table_association" "public_route_ass2" {
  subnet_id      = aws_subnet.subnet_public_2.id
  route_table_id = aws_route_table.route_public.id
}

// SUBNET PRIVATE
resource "aws_subnet" "subnet_private_1" {
  cidr_block              = var.subnet_private_1
  vpc_id                  = aws_vpc.aws_aka.id
  availability_zone       = var.availability_zone_a
  map_public_ip_on_launch = false

  tags = {
    Name = "Subnet private"
  }
}

resource "aws_subnet" "subnet_private_2" {
  cidr_block              = var.subnet_private_2
  vpc_id                  = aws_vpc.aws_aka.id
  availability_zone       = var.availability_zone_b
  map_public_ip_on_launch = false

  tags = {
    Name = "Subnet private"
  }
}



// ROUTE PRIVATE

resource "aws_route_table" "route_private" {
  vpc_id = aws_vpc.aws_aka.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = local.tags
}

resource "aws_route_table_association" "private_route_ass_1" {
  subnet_id      = aws_subnet.subnet_private_1.id
  route_table_id = aws_route_table.route_private.id
}

resource "aws_route_table_association" "private_route_ass_2" {
  subnet_id      = aws_subnet.subnet_private_2.id
  route_table_id = aws_route_table.route_private.id
}


// NAT GATEWAY
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.eip_nat.id
  subnet_id     = aws_subnet.subnet_public_1.id
  depends_on    = [aws_internet_gateway.gw]
  tags          = local.tags
}




// APPLICATION LOAD BALANCER

//APPLICATION LOAd BALANCER
resource "aws_alb" "alb" {
  name               = "aka-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.subnet_public_1.id, aws_subnet.subnet_public_2.id]
}

output "application_load_balancer" {
  value = aws_alb.alb.dns_name
}

resource "aws_alb_target_group" "target_group" {
  name        = "aka-alb-target"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.aws_aka.id
  target_type = "instance"

  lifecycle {
    create_before_destroy = true
  }

  health_check {
    path = "/"
    port = 80
  }
}


resource "aws_alb_listener" "listener_http" {
  load_balancer_arn = aws_alb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.target_group.arn
    type             = "forward"
  }
}


resource "aws_lb_target_group_attachment" "group_attachmentt" {
  target_group_arn = aws_alb_target_group.target_group.arn
  target_id        = aws_instance.ec2_instance_wordpress.id
  port             = 80
}

resource "aws_cloudfront_distribution" "cld_front" {
  origin {

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "match-viewer"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }

    domain_name = aws_alb.alb.dns_name
    origin_id   = aws_alb.alb.dns_name

  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Some comment"
  default_root_object = "/"

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    target_origin_id       = aws_alb.alb.dns_name
    viewer_protocol_policy = "allow-all"

    forwarded_values {
      headers      = []
      query_string = true

      cookies {
        forward = "all"
      }
    }
  }


  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
    minimum_protocol_version       = "TLSv1"
  }

  tags = {
    Name = "cloud front"
  }
}

output "aws_cloudfront_dns" {
  value = aws_cloudfront_distribution.cld_front.domain_name
}


resource "aws_route53_record" "route53_record" {
  for_each = toset(var.domain_names)
  zone_id  = aws_route53_zone.domain.zone_id
  name     = each.value
  type     = "A"
  alias {
    name                   = aws_cloudfront_distribution.cld_front.domain_name
    zone_id                = aws_cloudfront_distribution.cld_front.hosted_zone_id
    evaluate_target_health = false
  }
}

// ROUTE 53
resource "aws_route53_zone" "domain" {
  provider = aws.east
  name     = "arnaudkaninda.com"
}

output "ns" {
  value = aws_route53_zone.domain.name_servers
}















