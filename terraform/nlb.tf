# ====================
# Network Load Balancer
# ====================
# ネットワークロードバランサーの設定
resource "aws_lb" "unimarket-nlb" {
	name               = "unimarket-nlb"
	# インターネット向けかどうかの設定
	internal           = false
	load_balancer_type = "network"
	subnets            = [aws_subnet.private-web.id]
	# 削除保護を無効に設定
	enable_deletion_protection = false
	tags = {
		Name = "unimarket-nlb"
	}
}

# ターゲットグループの設定
resource "aws_lb_target_group" "unimarket-tg" {
	name        = "unimarket-tg"
	port        = 80
	protocol    = "TCP"
	vpc_id      = aws_vpc.unimarket.id
	target_type = "instance"
}

# リスナーの設定
resource "aws_lb_listener" "unimarket-listener" {
	# リスナーを設定するロードバランサーのARN
	load_balancer_arn = aws_lb.unimarket-nlb.arn
	port              = 80
	protocol          = "TCP"

	default_action {
		# デフォルトアクション（転送）
		type             = "forward"
		# 転送先のターゲットグループのARN
		target_group_arn = aws_lb_target_group.unimarket-tg.arn
	}
}

# ターゲットグループへのアタッチメント
resource "aws_lb_target_group_attachment" "unimarket-attachment" {
	# アタッチメントを設定するターゲットグループのARN
	target_group_arn = aws_lb_target_group.unimarket-tg.arn
	# アタッチするターゲットのID（インスタンスID）
	target_id        = aws_instance.unimarket-web.id
	port             = 80
}
