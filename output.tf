output "master" {
  value = aws_instance.master.public_ip
}

# output "worker1" {
#   value = aws_instance.worker1.public_ip
# }

output "worker2" {
  value = aws_instance.worker2.public_ip
}

# output "rds" {
#   value = aws_db_instance.multi_az_rds.endpoint
# } 