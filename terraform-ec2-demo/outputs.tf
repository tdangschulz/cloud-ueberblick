# ------------------------------------------------------------
# output: Entspricht den "Outputs" im CloudFormation-Template
# ------------------------------------------------------------
# Werden nach "terraform apply" angezeigt und lassen sich später
# jederzeit erneut abrufen mit: terraform output

output "public_ip" {
  description = "Öffentliche IP-Adresse der Instanz"
  value       = aws_instance.webserver.public_ip
}

output "website_url" {
  description = "URL der automatisch installierten Webseite"
  value       = "http://${aws_instance.webserver.public_ip}"
}
