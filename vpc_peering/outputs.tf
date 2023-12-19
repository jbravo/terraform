output "public_ip" {
     description = "The public IP address assigned to the instance"
     value       = try(aws_instance.vpc_a_ec2.public_ip, " ")
}

#output "peer_public_ip" {
#    description = "The public IP address assigned to the instance"
#    value       = try(aws_instance.vpc_b_ec2.public_ip, " ")
#}
