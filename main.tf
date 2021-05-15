
/*resource "aws_s3_bucket" "aka-terraform-backend" {
  bucket = var.bucket_name
  acl    = "private"

  //because i will use it as backend, so let turn it on
  versioning {
    enabled = true
  }

  // prevent to be destroy 
  lifecycle {
    prevent_destroy = true
  }

  // security
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = var.sse_algorithm
      }
    }
  }

  tags = local.tags
}

resource "aws_s3_bucket_public_access_block" "s3block" {
  bucket                  = aws_s3_bucket.aka-terraform-backend.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "dynamodb_name" {
  name           = var.dynamodb_name
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }


  tags = local.tags
}

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

// SUBNET-PUBLIC
resource "aws_subnet" "subnet_public" {
  cidr_block              = "10.0.1.0/24"
  vpc_id                  = aws_vpc.aws_aka.id
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name        = "terraform_sb_public_tp7"
    Environment = "development"
    Project     = "TP7"
  }
}
// SUBNET PRIVATE
/*resource "aws_subnet" "subnet_private" {
  cidr_block = "10.0.2.0/24"
  vpc_id     = aws_vpc.aws_aka.id
  //map_public_ip_on_launch = false
  availability_zone = "us-east-1a"

  tags = {
    Name = "Subnet private"
  }
}*/

output "aws_subnet_public" {
  value = aws_subnet.subnet_public.id
}

//EC2
resource "aws_instance" "ec2_instance_wordpress" {
  ami           = lookup(var.ami_id, var.region)
  instance_type = var.instance_type
  # Public Subnet assign to instance
  subnet_id = aws_subnet.subnet_public.id

  # Security group assign to instance
  vpc_security_group_ids      = [aws_security_group.allow_ssh.id]
  associate_public_ip_address = true
  count                       = 1

  # key name
  key_name = "admin"
  tags = {
    Name        = "terraform_ec2_tp7"
    Environment = "development"
    Project     = "TP7"
  }
}

output "aws_instance_id" {
  value = aws_instance.ec2_instance_wordpress[0].id
}

// SECURITY GROUP
resource "aws_security_group" "allow_ssh" {
  name        = "allow_SSH_http"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.aws_aka.id

  ingress {
    # SSH Port 22 allowed from any IP
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    # HTTP port 80 from any IP
    from_port   = 8080
    to_port     = 8080
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
    Name        = "terraform_sg_tp7"
    Environment = "development"
    Project     = "TP7"
  }

}

// INTERNET GATEWAY
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.aws_aka.id

  tags = local.tags
}

// NAT
/*resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.subnet_public.id
  depends_on    = [aws_internet_gateway.gw]
  tags          = local.tags
}*/

resource "aws_route_table" "route_public" {
  vpc_id = aws_vpc.aws_aka.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = local.tags
}

resource "aws_route_table_association" "private_route_ass" {
  subnet_id      = aws_subnet.subnet_public.id
  route_table_id = aws_route_table.route_public.id
}

//EIP
/*resource "aws_eip" "eip" {
  vpc      = true
  instance = aws_instance.ec2_instance_wordpress.id
  tags     = local.tags
}*/

// APPLICATION LOAD BALANCER
/*resource "aws_lb" "loadbl" {
  name                       = "loadbl"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.allow_ssh.id]
  subnets                    = aws_subnet.subnet_public.*.id
  enable_deletion_protection = true

  tags = local.tags
}*/


/*resource "aws_route_table" "route-public" {
  vpc_id = aws_vpc.aws_aka.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "public-route-table"
  }
}*/





