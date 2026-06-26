resource "aws_iam_role" "pod_s3_role" {
  name = "${var.project_name}-pod-s3-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession" 
        ]
        Effect = "Allow"
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_full_access" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = aws_iam_role.pod_s3_role.name
}

resource "kubernetes_service_account" "s3_sa" {
  metadata {
    name      = "s3-sa"
    namespace = "default"
  }
  
  depends_on = [module.eks]
}

resource "aws_eks_pod_identity_association" "app_s3_association" {
  cluster_name    = module.eks.cluster_name
  namespace       = "default"
  service_account = "default"
  role_arn        = aws_iam_role.pod_s3_role.arn
  depends_on = [
    aws_iam_role_policy_attachment.s3_full_access,
    kubernetes_service_account.s3_sa
  ]
}

module "ebs_csi_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"
  role_name             = "${var.project_name}-ebs-csi-role"
  attach_ebs_csi_policy = true 

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }
}

#TODO: Convert this block to terraform module
data "http" "lb_policy_json" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json"
}

resource "aws_iam_policy" "lb_controller" {
  name   = "${var.project_name}-lb-policy"
  policy = data.http.lb_policy_json.response_body
}

resource "aws_iam_role" "lb_controller_role" {
  name = "${var.project_name}-lb-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = ["sts:AssumeRole", "sts:TagSession"]
      Effect = "Allow"
      Principal = { Service = "pods.eks.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lb_attach" {
  policy_arn = aws_iam_policy.lb_controller.arn
  role       = aws_iam_role.lb_controller_role.name
}

resource "aws_eks_pod_identity_association" "lb_controller" {
  cluster_name    = module.eks.cluster_name
  namespace       = "kube-system"
  service_account = "aws-load-balancer-controller"
  role_arn        = aws_iam_role.lb_controller_role.arn
}
#! End of LB Controller IAM setup

#! Role for GitHub Actions Runner to access ECR
resource "aws_iam_role" "arc_runner_ecr_role" {
  name = "${var.project_name}-arc-runner-ecr-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = ["sts:AssumeRole", "sts:TagSession"]
      Effect = "Allow"
      Principal = { Service = "pods.eks.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "arc_runner_ecr_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
  role       = aws_iam_role.arc_runner_ecr_role.name
}

resource "aws_eks_pod_identity_association" "arc_runner_identity" {
  cluster_name    = module.eks.cluster_name
  namespace       = "actions-runner-system"
  service_account = "platform-runner-gha-rs-kube-mode"
  role_arn        = aws_iam_role.arc_runner_ecr_role.arn
}

resource "aws_eks_pod_identity_association" "arc_worker_identity" {
  cluster_name    = module.eks.cluster_name
  namespace       = "actions-runner-system"
  service_account = "default"
  role_arn        = aws_iam_role.arc_runner_ecr_role.arn
}
