module "vpc" {
  source = "../../modules/vpc"

  environment        = "local"
  cidr_block         = "10.0.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b"]
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets    = ["10.0.10.0/24", "10.0.20.0/24"]
}

module "eks" {
  source = "../../modules/eks"

  cluster_name   = "local-k8s"
  subnet_ids     = module.vpc.private_subnet_ids
  desired_nodes  = 2
  min_nodes      = 1
  max_nodes      = 3
  instance_types = ["t3.medium"]

  depends_on = [module.vpc]
}
