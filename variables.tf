variable "sse_algorithm" {
  description = "Algorith for see"
  type        = string
  default     = "AES256"
}

variable "dynamodb_name" {
  description = "Dynamo db name"
  type        = string
  default     = "kaninda-dynamodb_name"
}

variable "bucket_name" {
  description = "Name of bucket"
  type        = string
  default     = "onclekani.net"
}

variable "region" {
  default = "us-east-1"
}

variable "endpoint" {
  description = "Endpoint url"
  type        = string
  default     = "onclekani.net"
}

variable "domain_name" {
  description = "Domain name"
  type        = string
  default     = "onclekani.net"
}

variable "vpc_adr" {
  default = "10.0.0.0/16"
}

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

variable "instance_type_rds" {
  default = ""
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









