# us-east-2 리전 프로바이더
provider "aws" {
  region = var.region
}

# us-east-1(ohio) 리전 프로바이더(cloudfront 인증서용)
provider "aws" {
  alias = "virginia"
  region = "us-east-1"
}


provider "kubernetes" {
  host = data.aws_eks_cluster.cluster.endpoint
  #config_path = "~/.kube/config"
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token = data.aws_eks_cluster_auth.cluster.token
  
}

provider "helm" {
  kubernetes{
    host = data.aws_eks_cluster.cluster.endpoint
    #config_path = "~/.kube/config"
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    token = data.aws_eks_cluster_auth.cluster.token
  }
  
}


# HELM 차트로 alb controller 배포
resource "helm_release" "alb_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"

  values = [
    yamlencode({
      clusterName  = var.eks_cluster_name
      serviceAccount = {
	create = true
        name = "aws-load-balancer-controller"
        annotations = {
          "eks.amazonaws.com/role-arn" = data.aws_iam_role.alb_controller_role.arn
        }
      }
      service = {
        loadBalancer = {
          advancedConfig = {
            loadBalancer = {
              security_groups = [data.aws_security_group.alb_sg.id]
            }
          }
        }
      }
    })
  ]
}


resource "kubernetes_ingress_v1" "allcle-ingress" {
  metadata {
    name = var.eks_ingress_name
    annotations = {
      "kubernetes.io/ingress.class" = "alb"
      "alb.ingress.kubernetes.io/scheme" = "internet-facing"
      "alb.ingress.kubernetes.io/target-type" = "ip"
      "alb.ingress.kubernetes.io/subnets" = "${data.aws_subnet.public_a.id},${data.aws_subnet.public_c.id}"
      "alb.ingress.kubernetes.io/listen-ports" = "[{\"HTTP\": 80}, {\"HTTPS\": 443}]"
      "alb.ingress.kubernetes.io/ssl-redirect" = "443"
      "alb.ingress.kubernetes.io/certificate-arn" = data.aws_acm_certificate.issued.arn
    }
  }

  spec {
    ingress_class_name = "alb"
    rule {
      host = "www.allcle.net"
      http {
        path {
          path = "/"
          path_type = "ImplementationSpecific"
          backend {
            service {
              name = "nginx-service"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
  depends_on = [ helm_release.alb_controller ]  
}