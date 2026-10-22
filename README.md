# 🏗️ Infraestructura CrediYa (Terraform)

Este directorio contiene la Infraestructura como Código (IaC) para desplegar el sistema CrediYa en AWS.

## 📋 Arquitectura Desplegada

- **VPC**: Red privada con 2 subredes públicas.
- **RDS MySQL**: Base de datos relacional (db.t3.micro).
- **SQS**: 2 colas (notificaciones, capacidad de endeudamiento).
- **ECR**: 3 repositorios (autenticacion, solicitudes, reportes).
- **ECS Fargate**: Clúster para orquestar los contenedores.
- **ALB y API Gateway**: (Configuración pendiente en este archivo).
- **CloudWatch**: (Configuración pendiente en este archivo).

## 🚀 Cómo desplegar

### 1. Instalar Terraform
Descarga Terraform desde https://developer.hashicorp.com/terraform/downloads e instálalo.

### 2. Configurar credenciales de AWS
Asegúrate de tener el AWS CLI instalado y configura tus credenciales:
aws configure

### 3. Inicializar Terraform
terraform init

### 4. Planificar el despliegue
terraform plan

### 5. Aplicar el despliegue
terraform apply --auto-approve

### 6. Destruir la infraestructura (para no gastar dinero)
terraform destroy --auto-approve

## 🔐 Seguridad
- Se recomienda usar **AWS Secrets Manager** para las contraseñas de la base de datos.
- Los contenedores deben correr con un rol IAM de mínimo privilegio.

## 🐳 Imágenes de Docker
Primero debes autenticarte:
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin TU_AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com

Luego, para cada microservicio:
docker build -t crediya/autenticacion ./autenticacion
docker tag crediya/autenticacion:latest TU_AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/crediya/autenticacion:latest
docker push TU_AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/crediya/autenticacion:latest