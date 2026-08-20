output "environment_url" {
  description = "URL der laufenden Anwendung"
  value       = "http://${aws_elastic_beanstalk_environment.env.cname}"
}

output "environment_endpoint_url" {
  description = "Direkte Endpoint-URL der Beanstalk-Umgebung (z.B. Load-Balancer-DNS)"
  value       = aws_elastic_beanstalk_environment.env.endpoint_url
}
