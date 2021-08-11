terraform {
  required_version = ">= 0.14"

  backend "s3" {
    bucket  = "s3-conektasb-tfs"
    key     = "apps/reports-generator/worker/terraform.tfstate"
    region  = "us-east-1"
    profile = "conektasb"
    encrypt = true
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "conektasb"
}
