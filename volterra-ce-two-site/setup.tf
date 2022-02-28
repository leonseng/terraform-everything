provider "aws" {
  region = var.region
}

provider "volterra" {
  api_p12_file = var.api_p12_file
  url          = var.api_endpoint
}

resource "random_id" "id" {
  byte_length = 4
  prefix      = "${var.namespace}-"
}

data "aws_region" "current" {}

data "aws_availability_zones" "local_az" {
  state = "available"
  filter {
    name   = "region-name"
    values = ["${data.aws_region.current.name}"]
  }
}
