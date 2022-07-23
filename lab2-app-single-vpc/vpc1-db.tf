
# Binding DB into VPC, Minimum of 2 AZ are required
resource "aws_db_subnet_group" "db_subnet_group1" {
  name       = "db_subnet_group1"
  subnet_ids = [aws_subnet.sub2.id, aws_subnet.sub3.id]   # Setting up the DB to be in 2 AZ (Increase Availablity)

  tags = {
    Name = "DB subnet group"
  }
}

resource "aws_db_instance" "rds1" {
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group1.id
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  allocated_storage    = 10
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  name                 = "rds1"
  username             = "username1"
  password             = "password1"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
}

output "db_instance_address" {
  description = "The address of the RDS instance"
  value       = aws_db_instance.rds1.address
}