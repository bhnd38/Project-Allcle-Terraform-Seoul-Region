## EKS Cluster 데이터
data "aws_eks_cluster" "cluster" {
  name = var.eks_cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.eks_cluster_name
}

#-----------------------------------------------------------------------------

#VPC data
data "aws_vpc" "allcle_vpc" {
  filter {
    name = "tag:Name"
    values = ["ALLCLE-VPC"]
  }
}

# Subnet data
data "aws_subnet" "public_a" {
  filter {
    name = "tag:Name"
    values = ["public-a"]
  }
}

data "aws_subnet" "public_c" {
  filter {
    name = "tag:Name"
    values = ["public-c"]
  }
}

data "aws_subnet" "private_a" {
  filter {
    name = "tag:Name"
    values = ["private-a"]
  }
}

data "aws_subnet" "private_c" {
  filter {
    name = "tag:Name"
    values = ["private-c"]
  }
}

#-----------------------------------------------------------------------------

## 보안 그룹 데이터

# Bastion 보안 그룹 데이터 불러오기
data "aws_security_group" "bastion_sg" {
  filter {
    name = "tag:Name"
    values = [ "Bastion-SG" ]
  }
}

# ALB 보안 그룹 데이터 불러오기
data "aws_security_group" "alb_sg" {
  filter {
    name = "tag:Name"
    values = [ "ALB-SG" ]
  }
}

#-----------------------------------------------------------------------------

## AMI 데이터

# AMI AL2023 데이터 소스
data "aws_ami" "amazon_linux_2023" {
  most_recent = true

  filter {
    name = "name"
    values = ["al2023-ami-*"] # Amazon Linux 2023 이름 패턴
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

#-----------------------------------------------------------------------------

## ACM 인증서 데이터

# Cloudfront용 ACM 인증서 데이터 소스
data "aws_acm_certificate" "cloudfront" {
  provider = aws.virginia
  domain = "www.allcle.net"
  statuses = ["ISSUED"]
}

# ALB용 ACM 인증서 데이터 소스
data "aws_acm_certificate" "issued" {
  domain = "www.allcle.net"
  statuses = ["ISSUED"]
}

#-----------------------------------------------------------------------------

## IAM Role 데이터

# alb controller 역할 데이터 불러오기
data "aws_iam_role" "alb_controller_role" {
  name = "us-alb-controller-role"
}

# ALB 데이터 가져오기
# data "aws_lb" "alb" {
#   name = a
# }