# ============================================================
# BEISPIEL-TERRAFORM: Elastic Beanstalk mit bestehendem Dockerrun.aws.json
# ============================================================
# Nutzt das Docker-Image aus Dockerrun.aws.json (ghcr.io/.../meine-pipeline-app)
# und deployt es auf Elastic Beanstalk – "Single Container Docker"-Plattform.
# Elastic Beanstalk übernimmt automatisch: EC2-Instanz(en), Load Balancer,
# Auto Scaling, Health-Checks, Rolling-Deployments.


terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}


# ------------------------------------------------------------
# random_id: Suffix für den S3-Bucket-Namen
# ------------------------------------------------------------
# S3-Bucket-Namen müssen weltweit eindeutig sein (wie schon bei der
# BucketName-Übung im CloudFormation-S3-Template) – der zufällige
# Suffix erspart es, dass jede*r Teilnehmer*in manuell einen freien
# Namen suchen muss.
resource "random_id" "suffix" {
  byte_length = 4
}


# ------------------------------------------------------------
# aws_s3_bucket: Ablage für die Anwendungs-Versionen (Dockerrun.aws.json)
# ------------------------------------------------------------
# Elastic Beanstalk braucht die Deployment-Datei in S3, bevor daraus
# eine "Application Version" erstellt werden kann.
resource "aws_s3_bucket" "eb_bucket" {
  bucket = "eb-${var.app_name}-${random_id.suffix.hex}"

  tags = {
    Zweck = "Terraform-Beanstalk-Uebung"
  }
}

# Die eigentliche Dockerrun.aws.json aus dem Projekt-Root hochladen
resource "aws_s3_object" "dockerrun" {
  bucket = aws_s3_bucket.eb_bucket.id
  key    = "dockerrun-${filemd5("${path.module}/../Dockerrun.aws.json")}.json"
  source = "${path.module}/../Dockerrun.aws.json"
  etag   = filemd5("${path.module}/../Dockerrun.aws.json")
}


# ------------------------------------------------------------
# IAM-Rollen: Elastic Beanstalk braucht ZWEI Rollen
# ------------------------------------------------------------
# 1) Service-Rolle: mit der Beanstalk selbst (im Hintergrund) auf
#    andere AWS-Dienste zugreift (z.B. Health-Checks, CloudWatch)
# 2) EC2-Instanzprofil: mit der die EC2-Instanzen (die die
#    Container tatsächlich ausführen) auf AWS zugreifen dürfen
#
# In der AWS-Konsole werden diese beim ERSTEN Beanstalk-Environment
# automatisch angelegt – bei Terraform/API müssen wir sie selbst
# erstellen.

data "aws_iam_policy_document" "eb_service_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["elasticbeanstalk.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eb_service_role" {
  name               = "terraform-eb-service-role"
  assume_role_policy = data.aws_iam_policy_document.eb_service_assume.json
}

resource "aws_iam_role_policy_attachment" "eb_service_health" {
  role       = aws_iam_role.eb_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkEnhancedHealth"
}

resource "aws_iam_role_policy_attachment" "eb_service_updates" {
  role       = aws_iam_role.eb_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkManagedUpdatesCustomerRolePolicy"
}

data "aws_iam_policy_document" "eb_ec2_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eb_ec2_role" {
  name               = "terraform-eb-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.eb_ec2_assume.json
}

resource "aws_iam_role_policy_attachment" "eb_ec2_webtier" {
  role       = aws_iam_role.eb_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}

# aws_iam_instance_profile: EC2-Instanzen können nur "Instanzprofile"
# annehmen, keine IAM-Rollen direkt – deshalb dieser Wrapper.
resource "aws_iam_instance_profile" "eb_ec2_profile" {
  name = "terraform-eb-ec2-profile"
  role = aws_iam_role.eb_ec2_role.name
}


# ------------------------------------------------------------
# data "aws_elastic_beanstalk_solution_stack": aktuellste
# Single-Container-Docker-Plattform automatisch ermitteln
# ------------------------------------------------------------
# Gleiches Prinzip wie die automatische AMI-ID-Ermittlung im
# CloudFormation-EC2-Template – keine hart codierte, schnell
# veraltende Plattform-Version nötig.
data "aws_elastic_beanstalk_solution_stack" "docker" {
  most_recent = true
  name_regex  = "^64bit Amazon Linux 2023.*running Docker$"
}


# ------------------------------------------------------------
# aws_elastic_beanstalk_application: der "Ordner", der alle
# Versionen und Environments dieser App zusammenhält
# ------------------------------------------------------------
resource "aws_elastic_beanstalk_application" "app" {
  name        = var.app_name
  description = "Docker-Beispielprojekt (Terraform-Beanstalk-Uebung)"
}


# ------------------------------------------------------------
# aws_elastic_beanstalk_application_version: EINE konkrete,
# deploybare Version – zeigt auf die hochgeladene Dockerrun.aws.json
# ------------------------------------------------------------
resource "aws_elastic_beanstalk_application_version" "version" {
  name        = "v-${aws_s3_object.dockerrun.etag}"
  application = aws_elastic_beanstalk_application.app.name
  bucket      = aws_s3_bucket.eb_bucket.id
  key         = aws_s3_object.dockerrun.key
}


# ------------------------------------------------------------
# aws_elastic_beanstalk_environment: die eigentliche laufende
# Umgebung (EC2 + Load Balancer + Auto Scaling im Hintergrund)
# ------------------------------------------------------------
resource "aws_elastic_beanstalk_environment" "env" {
  name                = "${var.app_name}-env"
  application         = aws_elastic_beanstalk_application.app.name
  solution_stack_name = data.aws_elastic_beanstalk_solution_stack.docker.name
  version_label       = aws_elastic_beanstalk_application_version.version.name

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.eb_ec2_profile.name
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = var.instance_type
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "ServiceRole"
    value     = aws_iam_role.eb_service_role.name
  }

  # Single-Instanz statt Load-Balanced: reicht für die Schulung,
  # spart die (kostenpflichtige) Application Load Balancer-Ressource.
  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "EnvironmentType"
    value     = "SingleInstance"
  }
}
