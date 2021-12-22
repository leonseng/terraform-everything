provider "aws" {
  alias  = "use1"
  region = "us-east-1"
}

module "http-load-test-use1" {
  source = "./modules/http-load-test"
  providers = {
    aws = aws.use1
  }

  target = var.target
}

provider "aws" {
  alias  = "apne2"
  region = "ap-northeast-2"
}

module "http-load-test-apne2" {
  source = "./modules/http-load-test"
  providers = {
    aws = aws.apne2
  }

  target = var.target
}

provider "aws" {
  alias  = "apse2"
  region = "ap-southeast-2"
}

module "http-load-test-apse2" {
  source = "./modules/http-load-test"
  providers = {
    aws = aws.apse2
  }

  target = var.target
}

provider "aws" {
  alias  = "euc1"
  region = "eu-central-1"
}

module "http-load-test-euc1" {
  source = "./modules/http-load-test"
  providers = {
    aws = aws.euc1
  }

  target = var.target
}
