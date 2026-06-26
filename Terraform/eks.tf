module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "${var.project_name}-${var.environment}"
  cluster_version = "1.34"

  cluster_endpoint_public_access = true
  cluster_endpoint_private_access = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_addons = {
    coredns                = { resolve_conflicts_on_update = "PRESERVE" }
    kube-proxy             = { resolve_conflicts_on_update = "PRESERVE" }
    vpc-cni                = { resolve_conflicts_on_update = "PRESERVE" }
    eks-pod-identity-agent = { resolve_conflicts_on_update = "PRESERVE" }
    aws-ebs-csi-driver     = {
      resolve_conflicts_on_update = "PRESERVE"
      service_account_role_arn    = module.ebs_csi_irsa_role.iam_role_arn
    }
  }

  eks_managed_node_groups = {
    main = {
      min_size     = 1
      max_size     = 3
      desired_size = 2 

      instance_types = ["m7i-flex.large"]
      ami_type       = "AL2023_x86_64_STANDARD"
      capacity_type  = "ON_DEMAND" 
      subnets = module.vpc.private_subnets
    }
  }

  node_security_group_additional_rules = {
  ingress_istio_webhook = {
    description                   = "Allow API Server to reach Istio Webhook"
    protocol                      = "tcp"
    from_port                     = 15017
    to_port                       = 15017
    type                          = "ingress"
    source_cluster_security_group = true
  }
  }

  enable_cluster_creator_admin_permissions = true
  authentication_mode                      = "API_AND_CONFIG_MAP"

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }

  depends_on = [ module.vpc ]
}