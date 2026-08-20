# ------------------------------------------------------------
# variable: Entspricht den "Parameters" im CloudFormation-Template
# ------------------------------------------------------------
# Werte kommen entweder aus terraform.tfvars, per -var-Flag,
# oder — falls kein "default" gesetzt ist — Terraform fragt
# interaktiv beim "terraform apply" danach.

variable "aws_region" {
  description = "AWS-Region, in der die Ressourcen erstellt werden"
  type        = string
  default     = "eu-central-1"
}

variable "instance_type" {
  description = "EC2-Instanztyp (Free Tier: t2.micro / t3.micro)"
  type        = string
  default     = "t2.micro"

  validation {
    condition     = contains(["t2.micro", "t3.micro"], var.instance_type)
    error_message = "instance_type muss t2.micro oder t3.micro sein."
  }
}

variable "key_name" {
  description = <<-EOF
    Name eines vorhandenen EC2-Key-Pairs für SSH-Zugriff
    (muss vorher in der EC2-Konsole unter "Key Pairs" existieren).
  EOF
  type        = string
}
