# ====================
# EC2 Instance
# ====================
resource "aws_instance" "unimarket-web" {
	# 使用するAMIのID
	ami                         = "ami-0eda63ec8af4f056e"
	instance_type               = "t2.micro"
	subnet_id                   = aws_subnet.private-web.id
	# public IPを割り当てるかどうかの設定
	associate_public_ip_address = false
	vpc_security_group_ids      = [aws_security_group.unimarket-web-sg.id]
	key_name                    = var.key_name
	tags = {
		Name = "unimarket"
	}
}
