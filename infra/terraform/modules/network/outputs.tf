output "private_route_table_id" {
  value = aws_route_table.main_private.id
}

output "public_subnet_1a_id" {
  value = aws_subnet.main_public_1a.id
}

output "public_subnet_1b_id" {
  value = aws_subnet.main_public_1b.id
}

output "private_subnet_1a_id" {
  value = aws_subnet.main_private_1a.id
}

output "private_subnet_1b_id" {
  value = aws_subnet.main_private_1b.id
}

output "vpc_id" {
  value = aws_vpc.main.id
}
