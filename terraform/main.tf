terraform {
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 6.26" }
  }
}

provider "aws" {
  region  = var.region
  profile = var.aws_profile
}

module "vpc" {
  source = "./modules/vpc"
  region = var.region
}

module "sg" {
  source = "./modules/sg"
  vpc_id = module.vpc.vpc_id
}

module "iam" {
  source     = "./modules/iam"
  bucket_arn = module.s3.bucket_arn
}

module "s3" {
  source = "./modules/s3"
}

module "instance" {
  source                    = "./modules/instance"
  subnet_id                 = module.vpc.subnet_id
  security_group_id         = module.sg.security_group_id
  iam_instance_profile_name = module.iam.ssm_instance_profile_name
  region                    = var.region
}