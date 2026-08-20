# ============================================================
# BEISPIEL-TERRAFORM zum Erklären der wichtigsten Terraform-Befehle
# ============================================================
# Macht genau dasselbe wie cloudformation-ec2-webserver.yaml eine
# Ebene höher: EC2-Instanz + Security Group + Webserver per UserData.
# Guter Vergleichspunkt: gleiches Ergebnis, anderes Tool (IaC-Konzept
# ist toolunabhängig — Folie 95).


# ------------------------------------------------------------
# terraform { }: legt fest, welche Terraform- und Provider-Version
# gebraucht wird, und WO der State gespeichert wird
# ------------------------------------------------------------
# Ohne "backend"-Block landet der State lokal in terraform.tfstate
# (nur für Demo/Übung ok — im Team nutzt man einen Remote-Backend,
# z.B. S3 + DynamoDB-Lock, damit sich niemand gegenseitig überschreibt).
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}


# ------------------------------------------------------------
# provider "aws": WELCHE Cloud und WELCHE Region angesprochen wird
# ------------------------------------------------------------
# Entspricht bei CloudFormation der Region, die man oben rechts in
# der Konsole auswählt, bevor man den Stack erstellt.
provider "aws" {
  region = var.aws_region
}


# ------------------------------------------------------------
# data "aws_ami": fragt AWS zur Laufzeit nach der aktuellsten
# Amazon Linux 2023 AMI-ID der Region
# ------------------------------------------------------------
# Entspricht dem "LatestAmiId"-Parameter im CloudFormation-Template
# (AWS::SSM::Parameter::Value<AWS::EC2::Image::Id>) — auch hier kein
# manuelles Nachschauen der AMI-ID nötig.
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}


# ------------------------------------------------------------
# resource "aws_security_group": erlaubt HTTP (80) und SSH (22)
# ------------------------------------------------------------
# Entspricht "WebserverSecurityGroup" im CloudFormation-Template.
resource "aws_security_group" "webserver" {
  name        = "terraform-webserver-sg"
  description = "Erlaubt HTTP (80) und SSH (22)"

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # egress: ohne diesen Block darf die Instanz nichts nach draußen
  # schicken (z.B. kein "yum install" mehr) — anders als bei
  # CloudFormation, wo eine SecurityGroup standardmäßig ALLEN
  # ausgehenden Traffic erlaubt.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Zweck = "Terraform-IaC-Uebung"
  }
}


# ------------------------------------------------------------
# resource "aws_instance": die eigentliche EC2-Instanz
# ------------------------------------------------------------
# Entspricht "WebserverInstance" im CloudFormation-Template.
resource "aws_instance" "webserver" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.webserver.id]

  # user_data: identisches Startskript wie im CloudFormation-Template
  # (Fn::Base64 + UserData) — Terraform kodiert das automatisch.
  user_data = <<-EOF
    #!/bin/bash
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    echo "<h1>Hallo von Terraform! 🚀</h1><p>Diese EC2-Instanz wurde vollautomatisch per Terraform erstellt.</p>" > /var/www/html/index.html
  EOF

  tags = {
    Name = "Terraform-Webserver"
  }
}
