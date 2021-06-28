
/*


resource "aws_cloudfront_distribution" "cf" {
  enabled             = true
  aliases             = [var.endpoint]
  default_root_object = "index.html"

  origin {
    domain_name = aws_s3_bucket.aka-terraform-backend.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.aka-terraform-backend.bucket_regional_domain_name

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    target_origin_id       = aws_s3_bucket.aka-terraform-backend.bucket_regional_domain_name
    viewer_protocol_policy = "redirect-to-https"

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
    acm_certificate_arn      = aws_acm_certificate.cert.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2018"
  }

  tags = local.tags
}

resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI for ${var.endpoint}"
}

resource "aws_s3_bucket_policy" "s3policy" {
  bucket = aws_s3_bucket.aka-terraform-backend.id
  policy = data.aws_iam_policy_document.s3policy.json
}

resource "aws_acm_certificate" "cert" {
  provider                  = aws.us-east-1
  domain_name               = var.domain_name
  subject_alternative_names = ["*.${var.domain_name}"]
  validation_method         = "DNS"
  tags                      = local.tags
}

resource "aws_route53_record" "certvalidation" {
  for_each = {
    for d in aws_acm_certificate.cert.domain_validation_options : d.domain_name => {
      name   = d.resource_record_name
      record = d.resource_record_value
      type   = d.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.domain.zone_id
}

resource "aws_acm_certificate_validation" "certvalidation" {
  provider                = aws.us-east-1
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for r in aws_route53_record.certvalidation : r.fqdn]
}

resource "aws_route53_record" "websiteurl" {
  name    = var.endpoint
  zone_id = data.aws_route53_zone.domain.zone_id
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cf.domain_name
    zone_id                = aws_cloudfront_distribution.cf.hosted_zone_id
    evaluate_target_health = true
  }
}*/

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


output "aws_eip_public_ip" {
  value = aws_eip.eip_nat.public_ip
}


// SUBNET-PUBLIC
resource "aws_subnet" "subnet_public" {
  cidr_block              = var.subnet_public_adr
  vpc_id                  = aws_vpc.aws_aka.id
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zone_a

  tags = {
    Name        = "terraform_sb_public_tp7"
    Environment = "development"
    Project     = "TP7"
  }
}

output "aws_subnet_public" {
  value = aws_subnet.subnet_public.id
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


resource "aws_route_table_association" "public_route_ass" {
  subnet_id      = aws_subnet.subnet_public.id
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
  subnet_id     = aws_subnet.subnet_public.id
  depends_on    = [aws_internet_gateway.gw]
  tags          = local.tags
}




// APPLICATION LOAD BALANCER

//APPLICATION LOAd BALANCER
resource "aws_alb" "alb" {
  name               = "aka-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.subnet_private_1.id, aws_subnet.subnet_private_2.id]
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


// ROUTE 53
resource "aws_route53_record" "route53_record" {
  zone_id = data.aws_route53_zone.domain.zone_id
  name    = "www.onclekani.net"
  type    = "A"
  alias {
    name                   = aws_alb.alb.dns_name
    zone_id                = aws_alb.alb.zone_id
    evaluate_target_health = true
  }
}











