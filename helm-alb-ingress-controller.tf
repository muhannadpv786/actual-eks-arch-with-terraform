provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.eks-cluster.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.eks-cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

data "aws_eks_cluster_auth" "cluster" {
  name = aws_eks_cluster.eks-cluster.name
}

resource "helm_release" "alb_ingress" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"

  set {
    name  = "clusterName"
    value = var.cluster_name
  }

  set {
    name  = "serviceAccount.create"
    value = true
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "vpcId"
    value = aws_vpc.eks-vpc.id
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.alb_ingress_controller_iam_role.arn
  }

  depends_on = [
    aws_eks_node_group.ng-private,
    aws_eks_cluster.eks-cluster,
    aws_iam_role.alb_ingress_controller_iam_role,
    aws_iam_role_policy_attachment.alb_controller_iam_role_policy_attach,
    terraform_data.kubectl
  ]
}
