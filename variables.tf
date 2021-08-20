variable "sse_algorithm" {
  description = "Algorith for see"
  type        = string
  default     = "AES256"
}

variable "region" {
  default = "us-east-1"
}

variable "endpoint" {
  description = "Endpoint url"
  type        = string
  default     = "arnaudkaninda.com"
}

variable "domain_name" {
  description = "Domain name"
  type        = string
  default     = "arnaudkaninda.com"
}

//Les adresses
variable "vpc_adr" {
  default = "10.0.0.0/16"
}

variable "subnet_public_adr_1" {
  default = "10.0.1.0/24"
}

variable "subnet_public_adr_2" {
  default = "10.0.2.0/24"
}

variable "subnet_private_1" {
  default = "10.0.3.0/24"
}

variable "subnet_private_2" {
  default = "10.0.4.0/24"
}
// Fin adress

variable "enable_dns_hostnames" {
  type    = bool
  default = true
}

variable "enable_dns_support" {
  type    = bool
  default = true
}

variable "vpc_name" {
  default = "aws_vpc_name"
}


variable "ami_id" {
  default = {
    us-east-1 = "ami-09e67e426f25ce0d7"
  }
}

variable "instance_type_ec2" {
  default = "t2.micro"
}

variable "availability_zone_a" {
  default = "us-east-1a"
}

variable "availability_zone_b" {
  default = "us-east-1b"
}

variable "database_name" {
  default = "mydb"
}

variable "database_user" {
  default = "root"
}

variable "database_password" {
  default = "rootPassword"
}

variable "certificate_arn" {
  default = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"
}

variable "domain_names" {
  default = ["arnaudkaninda.com", "www.arnaudkaninda.com"]
}













