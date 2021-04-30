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
