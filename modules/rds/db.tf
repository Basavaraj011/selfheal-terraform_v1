resource "aws_db_subnet_group" "this" {
  name       = "selfheal-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "selfheal-db-subnet-group"
  }
}

resource "aws_db_instance" "this" {
  identifier = "selfheal-db"

  engine         = "sqlserver-ex"
  engine_version = "15.00.4455.2.v1"

  instance_class = "db.t3.micro"

  allocated_storage = 20
  max_allocated_storage = 100

  username = var.db_username
  password = var.db_password

  port = 1433

  db_subnet_group_name = aws_db_subnet_group.this.name

  vpc_security_group_ids = [
  var.rds_security_group_id
  ]


  publicly_accessible = true
  multi_az            = false

  skip_final_snapshot = true

  tags = {
    Name = "selfheal-db"
  }
}