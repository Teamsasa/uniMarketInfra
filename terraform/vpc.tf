# ====================
# VPC
# ====================
resource "aws_vpc" "unimarket" {
	cidr_block           = "10.0.0.0/16"
	# インスタンスの配置ポリシーをデフォルトに設定
	instance_tenancy     = "default"
	# DNSサポートを有効に設定
	enable_dns_support   = "true"
	# DNSホスト名の割り当てを有効に設定
	enable_dns_hostnames = "true"
	tags = {
		Name = "unimarket-VPC"
	}
}

# ====================
# Internet Gateway
# ====================
resource "aws_internet_gateway" "unimarket-igw" {
	vpc_id = aws_vpc.unimarket.id
	tags = {
		Name = "unimarket-igw"
	}
}

# ====================
# Subnet
# ====================
# パブリックサブネット
resource "aws_subnet" "unimarket-web" {
	vpc_id                  = aws_vpc.unimarket.id
	cidr_block              = "10.0.1.0/24"
	map_public_ip_on_launch = true
	availability_zone       = "ap-northeast-1a"
	tags = {
		Name = "public-web"
	}
}

# プライベートサブネット
resource "aws_subnet" "private-db-1" {
	vpc_id                  = aws_vpc.unimarket.id
	cidr_block              = "10.0.2.0/24"
	map_public_ip_on_launch = false
	availability_zone       = "ap-northeast-1a"
	tags = {
		Name = "private-db-1"
	}
}

# プライベートサブネット
resource "aws_subnet" "private-db-2" {
	vpc_id                  = aws_vpc.unimarket.id
	cidr_block              = "10.0.3.0/24"
	map_public_ip_on_launch = false
	availability_zone       = "ap-northeast-1c"
	tags = {
		Name = "private-db-2"
	}
}

# ====================
# DB Subnet Group
# ====================
# DB サブネットグループの設定
resource "aws_db_subnet_group" "unimarket-db-subnet" {
	name        = "unimarket-db-subnet"
	description = "unimarket-db-subnet"
	subnet_ids  =[aws_subnet.private-db-1.id,aws_subnet.private-db-2.id]
	tags = {
		Name = "unimarket-db-subnet"
	}
}

# ====================
# Security Group
# ====================
# WEBサーバーのセキュリティグループ
resource "aws_security_group" "unimarket-web-sg" {
	vpc_id      = aws_vpc.unimarket.id
	name        = "unimarket-web-sg"
	description = "unimarket-web-sg"
	tags = {
		Name = "unimarket-web-sg"
	}

	ingress {
		from_port   = 80
		to_port     = 80
		protocol    = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}

	ingress {
		from_port   = 22
		to_port     = 22
		protocol    = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}

	ingress {
		from_port   = 443
		to_port     = 443
		protocol    = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}

	egress {
		from_port   = 5432
		to_port     = 5432
		protocol    = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}

	egress {
		from_port   = 0
		to_port     = 0
		protocol    = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}
}

# DBサーバーのセキュリティグループ
resource "aws_security_group" "unimarket-db-sg" {
	name        = "unimarket-db-sg"
	description = "unimarket-db-sg"
	vpc_id      = aws_vpc.unimarket.id
	tags = {
		Name = "db-sg"
	}

	ingress {
		from_port       = 5432
		to_port         = 5432
		protocol        = "tcp"
		security_groups = [aws_security_group.unimarket-web-sg.id]
	}

	egress {
		from_port   = 0
		to_port     = 0
		protocol    = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}
}

# s3のセキュリティグループ
resource "aws_security_group" "unimarket-s3-sg" {
	name        = "unimarket-s3-sg"
	description = "unimarket-s3-sg"
	vpc_id      = aws_vpc.unimarket.id
	tags = {
		Name = "s3-sg"
	}

	ingress {
		from_port       = 80
		to_port         = 80
		protocol        = "tcp"
		security_groups = [aws_security_group.unimarket-web-sg.id]
	}

	egress {
		from_port   = 0
		to_port     = 0
		protocol    = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}
}

# ====================
# Route Table
# ====================
# パブリックルートテーブル
resource "aws_route_table" "unimarket-public" {
	vpc_id = aws_vpc.unimarket.id
	tags   = {
		Name = "public-route"
	}
}

# インターネットゲートウェイへのルート
resource "aws_route" "public_route" {
	gateway_id             = aws_internet_gateway.unimarket-igw.id
	route_table_id         = aws_route_table.unimarket-public.id
	destination_cidr_block = "0.0.0.0/0"
}

# ルートテーブルとパブリックサブネットの関連付け
resource "aws_route_table_association" "public_a" {
	subnet_id      = aws_subnet.unimarket-web.id
	route_table_id = aws_route_table.unimarket-public.id
}
