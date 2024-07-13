# ====================
# API Gateway
# ====================
# API Gatewayの設定
resource "aws_apigatewayv2_api" "unimarket-api" {
	name          = "unimarket-api"
	# API Gatewayのプロトコルの設定
	protocol_type = "HTTP"
}

# ステージの設定
resource "aws_apigatewayv2_stage" "default" {
	# ステージが属するAPIのID
	api_id      = aws_apigatewayv2_api.unimarket-api.id
	name        = "$default"
	# 変更があった場合に自動でデプロイするかの設定
	auto_deploy = true
}

# integrationの設定
resource "aws_apigatewayv2_integration" "unimarket-integration" {
	api_id                 = aws_apigatewayv2_api.unimarket-api.id
	integration_type       = "HTTP_PROXY"
	# インテグレーションのURI（ここではターゲットグループのARN）
	integration_uri        = aws_lb_listener.unimarket-listener.arn
	connection_type        = "VPC_LINK"
	connection_id          = aws_apigatewayv2_vpc_link.unimarket-vpc-link.id
	# インテグレーションのメソッドをANYに設定（どのHTTPメソッドでも受け付ける）
	integration_method = "ANY"
}

# ルートの設定
resource "aws_apigatewayv2_route" "default" {
	api_id    = aws_apigatewayv2_api.unimarket-api.id
	# ルートキーを設定（どのパスでも受け付ける）
	route_key = "ANY /{proxy+}"
	# このルートのリクエストを処理するインテグレーションのID
	target = aws_apigatewayv2_integration.unimarket-integration.id
}
