output "instance_name" {
  description = "Name of the instance"
  value       = aws_instance.ec2_instance.tags["Name"]
}

output "aws_Public_Ip" {
  description = "Public IP of Instance"
  value       = aws_instance.ec2_instance.public_ip
}

