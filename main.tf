# Provider AWS
provider "aws" {
  region = var.region
}

# Security Group para o MongoDB
resource "aws_security_group" "mongodb_sg" {
  name        = "mongodb-security-group"
  description = "Permitir acesso ao MongoDB a partir do EKS"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "mongodb-security-group"
  }
}

# Regra de Ingress para o EKS
resource "aws_security_group_rule" "mongodb_ingress" {
  type                     = "ingress"
  from_port                = 27017
  to_port                  = 27017
  protocol                 = "tcp"
  security_group_id        = aws_security_group.mongodb_sg.id
  source_security_group_id = var.eks_security_group_id
}

# Subnet Group para o MongoDB
resource "aws_db_subnet_group" "mongodb_subnet_group" {
  name        = "mongodb-subnet-group"
  description = "Subnet Group para MongoDB"
  subnet_ids  = [for s in aws_subnet.private : s.id]

  tags = {
    Name = "mongodb-subnet-group"
  }
}

# Instância DocumentDB (MongoDB)
resource "aws_docdb_cluster" "mongodb_cluster" {
  cluster_identifier       = "mongodb-cluster"
  engine                   = "docdb"
  master_username          = var.db_username
  master_password          = var.db_password
  backup_retention_period  = 7
  preferred_backup_window  = "07:00-09:00"
  vpc_security_group_ids   = [aws_security_group.mongodb_sg.id]
  db_subnet_group_name     = aws_db_subnet_group.mongodb_subnet_group.name
}

resource "aws_docdb_cluster_instance" "mongodb_instance" {
  count              = 2
  identifier         = "mongodb-instance-${count.index}"
  cluster_identifier = aws_docdb_cluster.mongodb_cluster.id
  instance_class     = "db.t3.medium"

  depends_on = [aws_docdb_cluster.mongodb_cluster]
}