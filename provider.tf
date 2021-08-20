provider "aws" {
  access_key = "AKIAV4XC5RDDHEJOKEQM"
  secret_key = "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"
  profile    = "default"
  region     = var.region
}

provider "aws" {
  access_key = "AKIAV4XC5RDDHEJOKEQM"
  secret_key = "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"
  alias      = "east"
  region     = "us-east-1"
}
