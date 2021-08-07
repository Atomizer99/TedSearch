output "wb_server1" {
  value = aws_instance.wb_server1.public_ip
  description = "The web srerver instance."
}