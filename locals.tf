
locals {
  tags = {
    Name        = var.domain_name
    Environment = "Developpement"
    created_by  = "Terraform"
  }
  cert_sans = ["www.${var.domain_name}", "cdn.${var.domain_name}", "*.${var.domain_name}"]
}
