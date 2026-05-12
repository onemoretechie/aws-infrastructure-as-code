output "vpc_id" {
  description = "ID of the created VPC."
  value       = aws_vpc.this.id
}

output "vpc_cidr_block" {
  description = "Primary CIDR block of the VPC."
  value       = aws_vpc.this.cidr_block
}

output "public_subnet_ids" {
  description = "IDs of the public subnets, ordered by AZ."
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private application subnets, ordered by AZ."
  value       = aws_subnet.private[*].id
}

output "database_subnet_ids" {
  description = "IDs of the isolated database subnets, ordered by AZ."
  value       = aws_subnet.database[*].id
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway attached to the VPC."
  value       = aws_internet_gateway.this.id
}

output "nat_gateway_ids" {
  description = "IDs of the NAT Gateways (empty list if nat_gateway_mode = none)."
  value       = aws_nat_gateway.this[*].id
}

output "availability_zones" {
  description = "AZs the VPC was spread across (echoed from input)."
  value       = var.availability_zones
}
