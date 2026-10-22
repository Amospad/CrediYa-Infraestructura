# ==========================================
# 1. CONFIGURACIÓN DEL PROVEEDOR (AWS)
# ==========================================
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# ==========================================
# 2. REDES (VPC, Subredes, Security Groups)
# ==========================================
resource "aws_vpc" "crediya_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = { Name = "crediya-vpc" }
}

resource "aws_subnet" "public_a" {
  vpc_id            = aws_vpc.crediya_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  tags = { Name = "crediya-subnet-public-a" }
}

resource "aws_subnet" "public_b" {
  vpc_id            = aws_vpc.crediya_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true
  tags = { Name = "crediya-subnet-public-b" }
}

resource "aws_security_group" "crediya_sg" {
  name        = "crediya-security-group"
  description = "Permitir trafico HTTP y MySQL"
  vpc_id      = aws_vpc.crediya_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8082
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ==========================================
# 3. BASE DE DATOS (RDS MySQL)
# ==========================================
resource "aws_db_instance" "crediya_mysql" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  db_name              = "crediya_db"
  username             = "admin"
  password             = "CrediYaPassword123!" # En producción usar Secrets Manager
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true

  vpc_security_group_ids = [aws_security_group.crediya_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.crediya_db_subnet.name
}

resource "aws_db_subnet_group" "crediya_db_subnet" {
  name       = "crediya-db-subnet-group"
  subnet_ids = [aws_subnet.public_a.id, aws_subnet.public_b.id]
}

# ==========================================
# 4. COLAS SQS (Comunicación asíncrona)
# ==========================================
resource "aws_sqs_queue" "sqs_notificaciones" {
  name = "crediya-sqs-notificaciones"
}

resource "aws_sqs_queue" "sqs_capacidad" {
  name = "crediya-sqs-capacidad-endeudamiento"
}

# ==========================================
# 5. REGISTRO DE IMÁGENES (ECR)
# ==========================================
resource "aws_ecr_repository" "repo_autenticacion" {
  name = "crediya/autenticacion"
}

resource "aws_ecr_repository" "repo_solicitudes" {
  name = "crediya/solicitudes"
}

resource "aws_ecr_repository" "repo_reportes" {
  name = "crediya/reportes"
}

# ==========================================
# 6. CLÚSTER ECS FARGATE
# ==========================================
resource "aws_ecs_cluster" "crediya_cluster" {
  name = "crediya-cluster"
}

# (Aquí irían las definiciones de las tareas y servicios ECS para cada microservicio,
#  el ALB y el API Gateway, pero eso requiere más archivos para no hacerlo gigante)