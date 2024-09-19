terraform {
  backend "s3" {
    bucket = "allcle-tf-backend"
    key = "terraform/terraform.tfstate"
  }
}


# ap-northeast-2 리전 프로바이더
provider "aws" {
  region = var.region
}

# us-east-1(ohio) 리전 프로바이더(cloudfront 인증서용)
provider "aws" {
  alias = "virginia"
  region = "us-east-1"
}


# Bastion 인스턴스 생성
resource "aws_instance" "bastion" {
  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public_a.id
  key_name      = var.public_key_pair
  vpc_security_group_ids = [
    aws_security_group.bastion_sg.id
  ]
  tags = {
    Name = "bastion"
  }
}


module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "~> 20.0"
  cluster_name    = var.eks_cluster_name
  cluster_version = "1.30"
  enable_cluster_creator_admin_permissions = true
  cluster_endpoint_public_access = true
  cluster_endpoint_private_access = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    
  }

  vpc_id     = aws_vpc.allcle_vpc.id
  subnet_ids = [aws_subnet.public_a.id, aws_subnet.public_c.id, aws_subnet.private_a.id, aws_subnet.private_c.id]

  eks_managed_node_groups = {
    allcle_eks_ng = {
      name           = var.node_group_name
      instance_types = [var.instance_type]
      ami_type       = "AL2023_x86_64_STANDARD"

      min_size     = 2
      max_size     = 4
      desired_size = 2

      # vpc_security_group_ids = [aws_security_group.eks_nodes_sg.id]
      subnet_ids = [ aws_subnet.private_a.id, aws_subnet.private_c.id ]
    }
  }

  tags = {
    Environment = "ALLCLE"
  }
}

# EKS 클러스터 보안 그룹에 인바운드 룰 추가
resource "aws_security_group_rule" "eks_from_bastion" {
  type = "ingress"
  from_port = 0
  to_port = 65535
  protocol = "tcp"
  security_group_id = module.eks.cluster_security_group_id
  source_security_group_id = aws_security_group.bastion_sg.id

  description = "Allow all TCP traffic from Bastion to EKS cluster"
}



# 자동생성된 노드 보안 그룹에 규칙 추가하기
resource "aws_security_group_rule" "custom_ingress" {
  type = "ingress"
  from_port = 443
  to_port = 443
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = data.aws_security_group.eks_nodes_sg.id
}