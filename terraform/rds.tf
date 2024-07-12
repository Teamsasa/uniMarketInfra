# ====================
# RDS Parameter Group
# ====================
resource "aws_db_parameter_group" "unimarket-db-pg" {
	name        = "uunimarket-db-pg"
	family      = "postgres14"
	description = "Uunimarket DB parameter group"

	parameter {
		name  = "rds.force_ssl"
		value = "0"
	}
}

# ====================
# RDS Instance
# ====================
# RDSサーバーの設定
resource "aws_db_instance" "main" {
	identifier             = "unimarket-db"
	db_name                = "unimarket"
	allocated_storage      = 20
	storage_type           = "gp2"
	engine                 = "postgres"
	engine_version         = "14.12"
	instance_class         = "db.t3.micro"
	password               = "${var.rds_pass}"
	username               = "${var.rds_username}"
	db_subnet_group_name   = "${aws_db_subnet_group.unimarket-db-subnet.name}"
	vpc_security_group_ids = ["${aws_security_group.unimarket-db-sg.id}"]
	parameter_group_name   = "${aws_db_parameter_group.unimarket-db-pg.name}"
	# データベースの作成後にスナップショットを作成しない
	skip_final_snapshot    = true
	# マルチAZの設定
	multi_az               = false
	availability_zone      = "${var.aws_region}"
	# パブリックアクセスの設定
	publicly_accessible    = false
	tags = {
		Name = "unimarket-db"
	}
}
