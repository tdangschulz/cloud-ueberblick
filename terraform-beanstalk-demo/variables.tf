variable "aws_region" {
  description = "AWS-Region, in der die Ressourcen erstellt werden"
  type        = string
  default     = "eu-central-1"
}

variable "app_name" {
  description = <<-EOF
    Name der Elastic-Beanstalk-Anwendung. Wird auch als Teil des
    S3-Bucket-Namens verwendet (zusammen mit einem Zufalls-Suffix,
    daher muss dieser Name selbst NICHT global eindeutig sein).
  EOF
  type        = string
  default     = "meine-pipeline-app"
}

variable "instance_type" {
  description = "EC2-Instanztyp für die Beanstalk-Umgebung (Free Tier: t2.micro / t3.micro)"
  type        = string
  default     = "t3.micro"
}
