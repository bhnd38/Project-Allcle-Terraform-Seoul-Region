# 고객 게이트웨이(CGW) 생성
resource "aws_customer_gateway" "Untangle_cgw" {
  bgp_asn = 65000
  ip_address = var.untangle_public_ip
  type = "ipsec.1"

  tags = {
    Name = "allcle-cgw"
  }

}
# VPN 게이트웨이 (VGW) 생성
resource "aws_vpn_gateway" "vpn_gw" {
  vpc_id = aws_vpc.allcle_vpc.id

  tags = {
    Name = "allcle-vgw"
  }
}

# VGW와 GGW를 VPN 연결
resource "aws_vpn_connection" "main" {
    vpn_gateway_id = aws_vpn_gateway.vpn_gw.id
    customer_gateway_id = aws_customer_gateway.Untangle_cgw.id
    type = "ipsec.1"
    static_routes_only = true # 정적 라우팅 사용 (BGP를 사용하려면 false로 설정)

    tunnel1_preshared_key = var.tunnel1_psk
    tunnel2_preshared_key = var.tunnel2_psk

    tags = {
      Name = "allcle-vpn"
    }
}

# VPN 연결 라우트 테이블에 온프레미스 네트워크 대역 추가
resource "aws_vpn_connection_route" "onpremise_network" {
    destination_cidr_block = "10.10.10.0/24"
    vpn_connection_id = aws_vpn_connection.main.id
    
}

# aws 프라이빗 라우트 테이블 A에 온프레미스 네트워크 추가
resource "aws_route" "route_to_onpremise_a" {
    route_table_id = aws_route_table.private_rt_a.id
    destination_cidr_block = "10.10.10.0/24"
    gateway_id = aws_vpn_gateway.vpn_gw.id
}

# aws 프라이빗 라우트 테이블 C에 온프레미스 네트워크 추가
resource "aws_route" "route_to_onpremise_c" {
    route_table_id = aws_route_table.private_rt_c.id
    destination_cidr_block = "10.10.10.0/24"
    gateway_id = aws_vpn_gateway.vpn_gw.id
}

