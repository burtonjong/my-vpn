terraform {
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 6.26" }
  }
}

provider "aws" {
  region = var.region
}

module "vpc" {
  source = "./modules/vpc"
  region = var.region
}

module "sg" {
  source = "./modules/sg"
  vpc_id = module.vpc.vpc_id
}

module "instance" {
  source            = "./modules/instance"
  subnet_id         = module.vpc.subnet_id
  security_group_id = module.sg.security_group_id
}